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
        switch self.priority {
        case .Food:
            
            if let _ = self.targetFood {}else {
                var nearbyFoods = self.handler.foods.sorted(by: {($0.node.worldPosition - self.node.position).getMagnitude()<($1.node.worldPosition - self.node.position).getMagnitude()})
                nearbyFoods.sort(by: {($0.node.worldPosition - self.node.worldPosition).getMagnitude()<($1.node.worldPosition - self.node.worldPosition).getMagnitude()})
                if nearbyFoods.count > 0 {
                    self.targetFood = nearbyFoods.first
                    self.target = self.targetFood!.node.worldPosition
                } else {
                    randomTarget()
                }
            }
        case .Water:
            var groundVerts = self.handler.drinkableVertices!
            groundVerts.sort(by: {($0.vector - self.node.position).getMagnitude()<($1.vector - self.node.position).getMagnitude()})
            if let position = groundVerts.first {
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
            randomTarget()
        }
    }
    
    func randomTarget() {
//        let organismHeight = (self.node.boundingBox.max.y+self.node.boundingBox.min.y)/2
//        let organismHeight: CGFloat = self.node.boundingBox.min.y
//        let organismHeight: CGFloat = 2.2
        let target = (coordinateTransfer(self.node.worldPosition + SCNVector3().random().toMagnitude(20))).setValue(Component: .y, Value: 2)
//        let targetPoint = self.handler.viableVerticies.sorted(by: {($0.vector-target).getMagnitude() < ($1.vector-target).getMagnitude()}).first?.vector
//        self.target = target
//        let targetPoint2 = self.handler.viableVerticies.first(where: {$0.vector == target})
//        print(target.x,target.y,target.z,targetPoint!.x,targetPoint!.y,targetPoint!.z)
//        if let point = targetPoint2?.vector {
//            self.target = point
//        }else {
//            let targetPoint2 = self.handler.viableVerticies.sorted(by: {($0.vector-self.node.worldPosition).getMagnitude()<($1.vector-self.node.worldPosition).getMagnitude()})
//            self.target = targetPoint2.first?.vector ?? SCNVector3().zero() // MARK: This will need fixing
//        }
        self.target = target
        
    }
    
    func coordinateTransfer(_ Vector: SCNVector3) -> SCNVector3 {
        let transfer: (CGFloat) -> (CGFloat) = {return CGFloat(Int($0/4)*4)}
        return SCNVector3(x: transfer(Vector.x), y: transfer(Vector.y), z: transfer(Vector.z))
    } // Finds a nearby point on the map
    
    func isNearTarget() -> Bool {
        return ((self.target - self.node.worldPosition).zero(.y).getMagnitude() <= self.Speed/2)
    }
    
    
    func movementHandler() {
        if self.dead == false {
            if isNearTarget() { // logic for setting new target
                if self.priority == .Water {
                    if self.inProcess {
                        self.drink()
                    }else if (self.handler.drinkableVertices.contains(where: {($0.vector == self.target)})) {
                        self.inProcess = true
                        self.drink()
                    }
                }else if self.priority == .Food { //MARK: Force Unwrapping Food
                    if let _ = self.targetFood {
                        if self.inProcess {
                            self.eat(Item: &self.targetFood!)
                            if self.inProcess == false {
                                self.targetFood = nil
                            }
                        }else if (self.node.worldPosition-self.targetFood!.node.worldPosition).zero(.y).getMagnitude() <= 4 {
                            self.inProcess = true
                        }
                    } else {
                        checkPriority()
                    }
                }else if self.priority == .Breed {
                    if self.inProcess {
                        self.breed()
                    }else {
                        if let checker = self.targetMate?.targetMate {
                            if checker.node != self.node {
                                self.targetMate = nil
                                checkPriority()
                            }else {
                                self.inProcess = true
                                self.targetMate!.inProcess = true
                                self.velocity = SCNVector3().zero()
                                self.targetMate!.velocity = SCNVector3().zero()
                            }
                        }else {
                            self.randomTarget()
                            checkPriority()
                        }
                    }
                }else {
                    checkPriority()
                    setTarget()
                }
            }else {
                move()
            }
            additionalPhysics() // overridable function
            look() // handles looking
            handleStats()
            if self.health <= 0 {
                self.die()
            }
//            if max(abs(self.node.worldPosition.x),abs(self.node.worldPosition.z)) > 200 {
//                reset()
//                print("E")
//            }
            
            if (self.node.worldPosition.zero(.y) - self.target.zero(.y)).getMagnitude() <= 0.5 {
                self.node.worldPosition = self.target.setValue(Component: .y, Value: 2-self.node.boundingBox.min.y+0.1)
                self.velocity = SCNVector3().zero()
            }
        }
    }
    
    func reset() {
        NSLog("RESET")
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
        
       let height = (self.thirstNode.boundingBox.max.y-self.thirstNode.boundingBox.min.y)

        self.thirstNode.geometry?.materials.first!.setValue(Float(height)*self.selectedAnimal!.thirst/100-Float(height/2), forKey: "threshold")
        self.hungerNode.geometry?.materials.first!.setValue(Float(height)*self.selectedAnimal!.hunger/100-Float(height/2), forKey: "threshold")
        self.healthNode.geometry?.materials.first!.setValue(Float(height)*self.selectedAnimal!.health/100-Float(height/2), forKey: "threshold")
        self.breedNode.geometry?.materials.first!.setValue(Float(height)*self.selectedAnimal!.breedingUrge/100-Float(height/2), forKey: "threshold")

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
//        let color: NSColor = #colorLiteral(red: 1, green: 0, blue: 0.9662935138, alpha: 1)
    }
    
}


