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
            var nearbyFoods = self.handler.foods.sorted(by: {($0.node.worldPosition - self.node.position).getMagnitude()<($1.node.worldPosition - self.node.position).getMagnitude()})
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
            randomTarget()
        case .Flee:
            randomTarget()
        default: //Idle
            randomTarget()
        }
    }
    
    func randomTarget() {
//        let organismHeight = (self.node.boundingBox.max.y+self.node.boundingBox.min.y)/2
        let organismHeight: CGFloat = self.node.boundingBox.min.y
        let target = (coordinateTransfer(self.node.worldPosition + SCNVector3().random().toMagnitude(20))).setValue(Component: .y, Value: 2)
//        let targetPoint = self.handler.viableVerticies.sorted(by: {($0.vector-target).getMagnitude() < ($1.vector-target).getMagnitude()}).first?.vector
//        self.target = target
        let targetPoint2 = self.handler.viableVerticies.first(where: {$0.vector == target})
//        print(target.x,target.y,target.z,targetPoint!.x,targetPoint!.y,targetPoint!.z)
        if let point = targetPoint2?.vector {
            self.target = point
        }else {
            randomTarget()
        }
        
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
                }else if self.priority == .Food {
                    let closestFood = self.handler.foods.sorted(by: {($0.node.worldPosition - self.node.position).getMagnitude()<($1.node.worldPosition - self.node.position).getMagnitude()})
                    if self.inProcess {
                        self.node.worldPosition = self.node.worldPosition.setValue(Component: .y, Value: 2-self.node.boundingBox.min.y)
                        self.node.physicsBody?.velocity = SCNVector3().zero()
                        self.eat(Item: closestFood.first!)
                    }else if (self.node.worldPosition-closestFood.first!.node.worldPosition).getMagnitude() <= 3 {
                        self.inProcess = true
                        self.eat(Item: closestFood.first!)
                        self.node.worldPosition = self.node.worldPosition.setValue(Component: .y, Value: 2-self.node.boundingBox.min.y)
                        self.node.physicsBody?.velocity = SCNVector3().zero()
                    }
                }else {
                    checkPriority()
                    setTarget()
                }
            }
            move()
            additionalPhysics() // overridable function
            look() // handles looking
            handleStats()
            if self.health <= 0 {
                self.die()
            }
            if self.node.worldPosition.y < 2 {
                self.node.worldPosition = self.node.worldPosition.setValue(Component: .y, Value: 2)
            }
        }
    }
    
    func syncNode() { // This function realigns the node's position with the physicsbody after rendering
        node.transform = node.presentation.transform
    }
}


    //MARK: - Calling Physics Handling

extension EnvironmentHandler {
    func process() {
        for i in animals {
            i.syncNode()
            i.movementHandler()
        }
//        handleMetal()
    }
}
