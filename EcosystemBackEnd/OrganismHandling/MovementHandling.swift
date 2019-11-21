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
        self.target = self.node.worldPosition + SCNVector3().random().setValue(Component: .y, Value: 2)
    }
    
    func move() {
        self.node.physicsBody?.velocity = (self.target-self.node.worldPosition).toMagnitude(1)
    }
    
    func isNearTarget() -> Bool {
        return (self.target - self.node.worldPosition).getMagnitude() <= (self.node.physicsBody?.velocity.getMagnitude())!
    }
    
    func movementHandler() {
        if isNearTarget() {
            setTarget()
        }
        move()
        additionalPhysics()
        look()
//        print(self.node.boundingBox.min.y+self.node.worldPosition.y)
//        print(self.node.worldPosition.y)
//        print(self.node.boundingSphere.center.y - CGFloat(self.node.boundingSphere.radius)+self.node.worldPosition.y)
    }
    
    func additionalPhysics() {
        
    }
}

extension EnvironmentHandler {
    func process() {
        for i in animals {
//            i.movementHandler()
        }
    }
}
