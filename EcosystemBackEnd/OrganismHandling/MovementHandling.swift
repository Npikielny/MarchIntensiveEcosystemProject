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
                randomTarget()
        }
        if self.affectedByGravity {
            self.target = self.target.setValue(Component: .y, Value: self.handler.mapValueAt(self.target))
        }
        self.inProcess = false
    }
    
    func coordinateTransfer(_ Vector: SCNVector3) -> SCNVector3 { //MARK: This Needs to be changed
        let transfer: (CGFloat) -> (CGFloat) = {return CGFloat(Int($0/4)*4)}
        return SCNVector3(x: transfer(Vector.x), y: transfer(Vector.y), z: transfer(Vector.z))
    } // Finds a nearby point on the map
    
    func isNearTarget() -> Bool {
        return ((self.target - self.node.worldPosition).getMagnitude() <= CGFloat(self.node.boundingSphere.radius * 2))
    }
    
    func movementHandler() {
        if self.dead == false {
            if isNearTarget() { // logic for setting new target
//                self.node.worldPosition = self.target
                self.inProcess = true
                decisionMaking()
            }else {
                self.move(self)
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
        }
    }
    
    fileprivate func decisionMaking() {
        switch self.priority {
            case .Water:
                self.drink()
                if self.thirst >= 100 {
                    checkPriority()
                    setTarget()
                }
            case .Food:
                if let _ = self.targetFood {
                    if self.eat(Item: &self.targetFood!) {
                        self.targetFood = nil
                        checkPriority()
                        setTarget()
                    }
                } else {
                    setTarget()
                }
            case .Breed:
                let success: Bool = {
                    if let node = self.targetMate?.targetMate?.node {
                        if node == self.node {
                            self.breed()
                            return true
                        }
                    }
                    return false
                }()
                self.inProcess = true
                if success == false {
                    self.inProcess = false
                    checkPriority()
                    setTarget()
                }
                if self.breedingUrge >= 100 {
                    self.inProcess = false
                    checkPriority()
                    setTarget()
                }
            default:
                checkPriority()
                setTarget()
        }
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
        self.breedNode.geometry?.materials.first!.setValue(Float(height)*(100-self.selectedAnimal!.breedingUrge)/100-Float(height/2), forKey: "threshold")
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
