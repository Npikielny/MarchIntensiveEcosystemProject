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
        case .Water:
            var groundVerts = self.handler.viableVerticies!
            groundVerts.removeAll(where: {$0.isNearWater == false})
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
        let target = (self.node.worldPosition + SCNVector3().random().toMagnitude(20))
        let targetPoint = self.handler.viableVerticies.sorted(by: {($0.vector-target).getMagnitude() < ($1.vector-target).getMagnitude()})
        self.target = targetPoint.first!.vector.setValue(Component: .y, Value: 2-organismHeight)
    }
    
    func isNearTarget() -> Bool {
        return ((self.target - self.node.worldPosition).zero(.y).getMagnitude() <= self.Speed/2)
    }
    
    
    func movementHandler() {
        if self.dead == false {
            if isNearTarget() { // logic for setting new target
                if self.priority == .Water {
                    if self.inProcess {
                        self.drink()
                    }else if (self.handler.viableVerticies.contains(where: {($0.vector == self.target) && ($0.isNearWater == true)})) {
                        self.inProcess = true
                        self.drink()
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
    }
}
