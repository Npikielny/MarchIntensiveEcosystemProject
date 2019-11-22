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
            randomTarget()
        case .Water:
            randomTarget()
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
        self.target = (self.node.worldPosition + SCNVector3().random().toMagnitude(20)).setValue(Component: .y, Value: 2-organismHeight)
    }
    
    func isNearTarget() -> Bool {
        return ((self.target - self.node.worldPosition).zero(.y).getMagnitude() <= self.Speed/2)
    }
    
    func handleStats() {
        self.hunger = Float(CGFloat(self.hunger)-((self.node.physicsBody?.velocity.getMagnitude())! * 0.001))
    }
    
    func movementHandler() {
        if isNearTarget() { // logic for setting new target
            print("NEAR")
            setTarget()
        }
        move() // handling movement
        additionalPhysics() // overridable function
        look() // handles looking
        handleStats()
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
