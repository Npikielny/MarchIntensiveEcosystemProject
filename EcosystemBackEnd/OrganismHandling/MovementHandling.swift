//
//  MovementHandling.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/20/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

extension Animal {
    func setTarget() {
        self.targetTries = 0
        switch self.priority {
            case .Food:
                if self.hunter {
                    if let _ = (self as! Hunter).targetAnimal {}else {
                        if getFood() == false {
                            self.checkPriority()
                            self.setTarget()
                        }
                    }
                }else {
                    if let _ = self.targetFood {}else {
                        if getFood() == false {
                            self.checkPriority()
                            self.setTarget()
                        }
                    }
                }
                
            case .Water:
                var groundVerts = self.handler.drinkableVertices!
                groundVerts.removeAll(where: {($0.vector - self.node.worldPosition).getMagnitude() > self.speciesData.perceptionCap})
                if let position = groundVerts.min(by: {($0.vector - self.node.position).getMagnitude()<($1.vector - self.node.position).getMagnitude()}) {
                    self.target = position.vector
                }else {
                    checkPriority()
                    randomTarget()
                }
                
            case .Breed:
                if let _ = self.targetMate {
                    self.targetMate = nil
                    checkPriority()
                } else {
                    var breedingTargets = self.handler.animals
                    breedingTargets.removeAll(where: {$0.node.worldPosition == self.node.worldPosition})
                    breedingTargets.removeAll(where: {$0.sex == self.sex})
                    breedingTargets.removeAll(where: {$0.speciesData.species != self.speciesData.species})
                    breedingTargets.sort(by: {($0.node.worldPosition - self.node.worldPosition).getMagnitude()<($1.node.worldPosition - self.node.worldPosition).getMagnitude()})
                    
                    for index in 0..<breedingTargets.count {
                        if let _ = self.targetMate{} else {
                            if let _ = breedingTargets[index].targetMate {} else {
                                breedingTargets[index].breedRequest(self)
                            }
                        }
                    }
                    
                    if let _ = self.targetMate {} else {
                        checkPriority()
                        randomTarget()
                    }
                }
                
                if let _ = self.targetMate {
                    if ((self.targetMate?.node.worldPosition)! - self.node.worldPosition).getMagnitude() < 0.5 {
                        self.inProcess = true
                        self.targetMate?.inProcess = true
                    }else {self.target = (self.targetMate!.node.worldPosition + self.node.worldPosition).scalarMultiplication(Scalar: 0.5)}
                }else {
                    checkPriority()
                    randomTarget()
                }
                
            case .Flee:
                randomTarget()
                
            default: //Idle
                self.priority = .Idle
                randomTarget()
        }
        if self.affectedByGravity {
            self.target = self.target.setValue(Component: .y, Value: self.handler.mapValueAt(self.target))
        }else {
            let h = self.handler.mapValueAt(self.target)
            if self.target.y < h {
                self.target = self.target.setValue(Component: .y, Value: h)
            }
        }
        if self.priority != .Hunt {
            self.inProcess = false
        }
    }
    
    func isNearTarget() -> Bool {
        let distance: CGFloat = {
//            if self.affectedByGravity {
//                return (self.target - self.node.worldPosition).zero(.y).getMagnitude()
//            }else {
                return (self.target - self.node.worldPosition).getMagnitude()
//            }
        }()
//        let d2 = (self.target - (self.node.worldPosition + self.velocity + SCNVector3(0,-9.807,0).scalarMultiplication(Scalar: 1/30))).getMagnitude()
//        if d2 < distance {
//            return false
//        }else {
        return (distance - CGFloat(self.node.boundingSphere.radius / 2) <= CGFloat(self.targetTries) / 500 + self.Speed/30)
//        }
        
//        SCNSphere(radius: CGFloat(self.selectedAnimal!.targetTries)/500+CGFloat(self.selectedAnimal!.node.boundingSphere.radius/2)+self.selectedAnimal!.Speed/30)
    }
    
    func movementHandler() {
        let correction: () -> () = {
            self.inProcess = false
            self.checkPriority()
            self.setTarget()
        }
        if self.dead == false {
            if self.inProcess == false {
                self.targetTries += 1
            }else {
                switch self.priority {
                case .Water:
                    if self.thirst >= self.maxthirst {
                        correction()
                    }
                case .Food:
                    if self.hunger >= self.maxhunger {
                        correction()
                    }
                case .Breed:
                    if self.breedingUrge >= self.maxbreedingUrge {
                        correction()
                    }
                case .Hunt:
                    if self.hunter {
                        if let targetAnimal = (self as! Hunter).targetAnimal {
                            self.target = targetAnimal.node.worldPosition
                        }else {
                            if getFood() == false {
                                self.checkPriority()
                                self.setTarget()
                            }
                        }
                    }else {
                        checkPriority()
                    }
                default:
                    break
                }
            }
            if self.targetTries > 1575 {
                self.checkPriority()
                self.setTarget()
            }
            if self.inProcess {
                executeProcesses()
            }else {
                if isNearTarget() { // logic for setting new target
    //                self.node.worldPosition = self.target
                    switch self.priority { //MARK: .Flee
                    case .Idle:
                        self.checkPriority()
                        self.setTarget()
                    default:
                        self.inProcess = true
                        executeProcesses()
                    }
                }else {
                    if self.affectedByGravity {
                        if self.velocity.y == 0 {
                            self.move(self)
                        }
                    }else {
                        self.move(self)
                    }
                }
            }
            additionalPhysics() // overridable function
            look() // handles looking
            handleStats()
//            if max(abs(self.node.worldPosition.x),abs(self.node.worldPosition.z)) > 200 {
//                reset()
//            }
            
//            if (self.node.worldPosition.zero(.y) - self.target.zero(.y)).getMagnitude() <= 0.5 {
//                let bm = self.handler.mapValueAt(self.node.worldPosition)
//                self.node.worldPosition = self.target.setValue(Component: .y, Value: bm-self.node.boundingBox.min.y)
//                self.velocity = SCNVector3().zero()
//            }
            self.barring = []
        }
        self.nearbyHunters = []
    }
    
    fileprivate func executeProcesses() {
        switch self.priority {
        case .Food:
            if let _ = self.targetFood {
                if self.eat(Item: &self.targetFood!) {
                    self.targetFood = nil
                    self.inProcess = false
                }
            }else {
                _ = self.getFood()
                self.inProcess = false
            }
        case .Breed:
            if let check = self.targetMate?.targetMate {
                if check == self {
                    if self.breed() {
                        self.inProcess = false
                    }
                }else {
                    if findMate() == false {
                        self.checkPriority()
                        self.setTarget()
                    }
                    self.inProcess = false
                }
            }else {
                if findMate() == false {
                    self.checkPriority()
                    self.setTarget()
                }
                self.inProcess = false
            }
        case .Water:
            if self.drink() {
                self.inProcess = false
            }
        case .Hunt:
            if let targetAnimal = ((self as! Hunter).targetAnimal) {
                    self.attack(targetAnimal)
            }else {
                if getFood() == false {
                    self.checkPriority()
                    self.setTarget()
                }
            }
        default:
            self.inProcess = false
        }
    }
    
    func getFood() -> Bool {
        var foods = self.handler.foods
        let acceptableFoods = foodConversion[self.speciesData.foodType]
        foods.removeAll(where: {($0.node.worldPosition - self.node.worldPosition).getMagnitude() > self.speciesData.perceptionCap})
        foods.removeAll(where: {acceptableFoods?.contains($0.dataStructure.foodEaterType) == false})
        foods.removeAll(where: {$0.foodValue <= 0})
        if foods.count > 0 {
            self.targetFood = foods.min(by: {($0.node.worldPosition - self.node.worldPosition).getMagnitude() < ($1.node.worldPosition - self.node.worldPosition).getMagnitude()})
            self.target = self.targetFood!.node.worldPosition
            return true
        }else {
            if self.hunter == true {
                var animalFoods = self.handler.animals
                animalFoods.removeAll(where: {$0.speciesData.name == self.speciesData.name})
//                animalFoods.removeAll(where: {($0.node.worldPosition - self.node.worldPosition).getMagnitude() > self.speciesData.perceptionCap})
//                for i in animalFoods {
//                    i.nearbyHunters.append(self)
//                }
                if let checkedAnimal = animalFoods.min(by: {($0.node.worldPosition - self.node.worldPosition).getMagnitude() < ($1.node.worldPosition - self.node.worldPosition).getMagnitude()}) {
                    (self as! Hunter).targetAnimal = checkedAnimal
                    self.priority = .Hunt
                    self.inProcess = true
                    return true
                }else {
                    self.barring.append(.Food)
                    return false
                }
            }else {
                self.barring.append(.Food)
                return false
            }
        }
    }
    
    func findMate() -> Bool {
        var potentialMates = self.handler.animals
        potentialMates.removeAll(where: {$0.speciesData != self.speciesData})
        potentialMates.removeAll(where: {$0.breedingUrge > 70})
        potentialMates.removeAll(where: {($0.node.worldPosition - self.node.worldPosition).getMagnitude() > self.speciesData.perceptionCap})
        potentialMates.sort(by: {($0.node.worldPosition - self.node.worldPosition).getMagnitude() < ($1.node.worldPosition - self.node.worldPosition).getMagnitude()})
        for i in potentialMates {
            if self.breedRequest(i) {
                return true
            }
        }
        self.barring.append(.Breed)
        return false
    }
    
    func attack(_ Defender: Animal) {
        Defender.health -= self.speciesData.attackDamage
    }
    
    static func == (left: Animal, right: Animal) -> Bool {
        return left.node == right.node
    }
}


    //MARK: - Calling Physics Handling

extension EnvironmentHandler {
    
    func setStats() {
        self.thirstNode.worldPosition = self.selectedAnimal!.node.worldPosition.setValue(Component: .y, Value: 8)
        self.hungerNode.worldPosition = self.selectedAnimal!.node.worldPosition.setValue(Component: .y, Value: 8)+SCNVector3(0.5, 0, 0)
        self.healthNode.worldPosition = self.selectedAnimal!.node.worldPosition.setValue(Component: .y, Value: 8)+SCNVector3(1.0, 0, 0)
        self.breedNode.worldPosition = self.selectedAnimal!.node.worldPosition.setValue(Component: .y, Value: 8)+SCNVector3(1.5, 0, 0)
        self.targetNode.worldPosition = self.selectedAnimal!.target
        
        self.targetNode.geometry = SCNSphere(radius: CGFloat(self.selectedAnimal!.targetTries)/500+CGFloat(self.selectedAnimal!.node.boundingSphere.radius/2)+self.selectedAnimal!.Speed/30)
        self.targetNode.geometry?.materials.first!.diffuse.contents = NSColor.systemOrange.withAlphaComponent(100)
       let height = (self.thirstNode.boundingBox.max.y-self.thirstNode.boundingBox.min.y)

        self.thirstNode.geometry?.materials.first!.setValue(Float(height)*self.selectedAnimal!.thirst/self.selectedAnimal!.maxthirst-Float(height/2), forKey: "threshold")
        self.hungerNode.geometry?.materials.first!.setValue(Float(height)*self.selectedAnimal!.hunger/self.selectedAnimal!.maxhunger-Float(height/2), forKey: "threshold")
        self.healthNode.geometry?.materials.first!.setValue(Float(height)*self.selectedAnimal!.health/self.selectedAnimal!.maxhealth-Float(height/2), forKey: "threshold")
        self.breedNode.geometry?.materials.first!.setValue(Float(height)*(100-self.selectedAnimal!.breedingUrge)/self.selectedAnimal!.maxbreedingUrge-Float(height/2), forKey: "threshold")
        self.statsNode.worldPosition = self.selectedAnimal!.node.worldPosition.setValue(Component: .y, Value: 3+4+1.5)
//        let statString = "Hunger: "+String(Int(self.hunger))+"\r\n"+"Thirst: "+String(Int(self.thirst))+"\r\n"+"Health: "+String(Int(self.health))
       let priorityString: String = {
        switch self.selectedAnimal!.priority {
           case .Idle:
               return "Idle"
           case .Food:
               return "Food"
           case .Water:
               return "Water"
           case .Breed:
               return "Breed"
           default:
               return "Nil"
           }
       }()
        let animalName = self.selectedAnimal?.node.name
        let sexSTR:String = {
            if self.selectedAnimal?.sex == .Male {
                return " ♂"
            }else {
                return " ♀"
            }
        }()
        let ageSTR = String(Int(self.selectedAnimal!.age))
       let text = SCNText(string: animalName! + sexSTR + " – " + priorityString + " (" + ageSTR + ")", extrusionDepth: 0.1)
       text.font = NSFont.systemFont(ofSize: 0.5)
        self.statsNode.geometry = text
    }
}
