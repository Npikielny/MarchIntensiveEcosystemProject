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
            let nearbyFoods = self.handler.foods.sorted(by: {($0.node.worldPosition - self.node.position).getMagnitude()<($1.node.worldPosition - self.node.position).getMagnitude()})
            if let position = nearbyFoods.first?.node.worldPosition {
                self.target = position
            }else {
                randomTarget()
            }
        case .Water:
            var groundVerts = self.handler.drinkableVertices!
            groundVerts.sort(by: {($0.vector - self.node.position).getMagnitude()<($1.vector - self.node.position).getMagnitude()})
            if let position = groundVerts.first {
                self.target = position.vector
            }else {
                randomTarget()
            }
        case .Breed:
            if let _ = self.targetMate {}else {
                var breedingTargets = self.handler.animals
                breedingTargets.removeAll(where: {$0.node == self.node})
                breedingTargets.sort(by: {($0.node.worldPosition - self.node.worldPosition).getMagnitude()<($1.node.worldPosition - self.node.worldPosition).getMagnitude()})
                for index in 0..<breedingTargets.count {
                    if let _ = self.targetMate{} else {
                        if let _ = breedingTargets[index].targetMate {} else {
                            breedingTargets[index].breedRequest(self)
                        }
                    }
                }
                if let _ = self.targetMate {} else {
                    randomTarget()
                }
            }
            
            if let _ = self.targetMate {
                if ((self.targetMate?.node.worldPosition)! - self.node.worldPosition).getMagnitude() < 4 {
                    self.inProcess = true
                    self.targetMate?.inProcess = true
                }else {self.target = (self.targetMate!.node.worldPosition + self.node.worldPosition).scalarMultiplication(Scalar: 0.5)}
            }else {
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
                    let closestFood = self.handler.foods.sorted(by: {($0.node.worldPosition - self.node.position).getMagnitude()<($1.node.worldPosition - self.node.position).getMagnitude()})
                    if self.inProcess {
//                        self.node.worldPosition = self.node.worldPosition.setValue(Component: .y, Value: 2-self.node.boundingBox.min.y)
//                        self.node.physicsBody?.velocity = SCNVector3().zero()
                        self.eat(Item: closestFood.first!)
                    }else if (self.node.worldPosition-closestFood.first!.node.worldPosition).zero(.y).getMagnitude() <= 4 {
                        self.inProcess = true
                        self.eat(Item: closestFood.first!)
//                        self.node.worldPosition = self.node.worldPosition.setValue(Component: .y, Value: 2-self.node.boundingBox.min.y)
//                        self.node.physicsBody?.velocity = SCNVector3().zero()
                    }
                }else if self.priority == .Breed {
                    if self.inProcess {
                        self.breed()
                    }else {
                        if let checker = self.targetMate?.targetMate {
                            if checker.node != self.node {
                                self.setTarget()
                            }else {
                                self.inProcess = true
                                self.targetMate!.inProcess = true
                                self.velocity = SCNVector3().zero()
                                self.targetMate!.velocity = SCNVector3().zero()
                            }
                        }else {
                            self.randomTarget()
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
//            if self.node.worldPosition.y < self.height/2+2 {
//                self.node.worldPosition = self.node.worldPosition.setValue(Component: .y, Value: self.height/2)
//                self.velocity = (self.velocity.zero(.y))
//                if self.node.worldPosition.y < self.height/2+2 {
//                    reset()
//                }
//            }
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
    
    func syncNode() { // This function realigns the node's position with the physicsbody after rendering
        node.transform = node.presentation.transform
    }
}


    //MARK: - Calling Physics Handling

extension EnvironmentHandler {
    
    func commenceEngine() {
        self.initialized = true
        
        self.Scene.rootNode.addChildNode(thirstNode)
        self.Scene.rootNode.addChildNode(hungerNode)
        self.Scene.rootNode.addChildNode(healthNode)
        self.Scene.rootNode.addChildNode(statsNode)
        self.Scene.rootNode.addChildNode(breedNode)
        self.Scene.rootNode.addChildNode(targetNode)

        self.thirstNode.isHidden = true
        self.hungerNode.isHidden = true
        self.healthNode.isHidden = true
        self.statsNode.isHidden = true
        self.breedNode.isHidden = true
        self.targetNode.isHidden = true
    }
    
    func process() {
        if self.initialized {
            for i in animals {
                i.syncNode()
                i.movementHandler()
            }
            for i in foods {
                i.syncNode()
            }
    //        handleMetal()
            if let _ = self.terrain {
                if let individual = self.selectedAnimal {
                    self.terrain.node.geometry?.materials.first!.setValue(Float(individual.node.worldPosition.x), forKey: "x")
                    self.terrain.node.geometry?.materials.first!.setValue(Float(individual.node.worldPosition.z), forKey: "z")
                    setStats()
                    self.thirstNode.isHidden = false
                    self.hungerNode.isHidden = false
                    self.healthNode.isHidden = false
                    self.statsNode.isHidden = false
                    self.breedNode.isHidden = false
                    self.targetNode.isHidden = false
                }else {
                    self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "x")
                    self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "z")
                    self.thirstNode.isHidden = true
                    self.hungerNode.isHidden = true
                    self.healthNode.isHidden = true
                    self.statsNode.isHidden = true
                    self.breedNode.isHidden = true
                    self.targetNode.isHidden = true
                }
            }
        }
    }
    
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
       let text = SCNText(string: animalName! + " – " + priorityString, extrusionDepth: 0.1)
       text.font = NSFont.systemFont(ofSize: 0.5)
        self.statsNode.geometry = text
//        let color: NSColor = #colorLiteral(red: 1, green: 0, blue: 0.9662935138, alpha: 1)
    }
    
}


