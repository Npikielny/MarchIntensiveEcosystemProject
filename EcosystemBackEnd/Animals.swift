//
//  Animals.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/13/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Animal {
    var node: SCNNode
    var lookType: LookType
    var handler: EnvironmentHandler
    var hunger: Int = 0
    var thirst: Int = 0
    var health: Int = 1
    var age: Int = 0
    init(Position: SCNVector3, Species: String, lookType: LookType, Handler: EnvironmentHandler) {
        self.node = getPrefab(Species+".scn", Shaders: nil)
        self.node.name = Species
        self.lookType = lookType
        self.handler = Handler
        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.node, options: [:]))
        self.node.physicsBody?.angularVelocityFactor = SCNVector3().zero()
        self.node.worldPosition = Position
        self.handler.animals.append(self)
        
    }
    
    func die() {
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: CGFloat(2 * M_PI)))
        spin.duration = 3
        self.node.addAnimation(spin, forKey: "rotation")
    }
}

class Rabbit: Animal {
    init(Position: SCNVector3, Handler: EnvironmentHandler) {
        super.init(Position: Position, Species: "rabbit", lookType: .Forward, Handler: Handler)
    }
}

enum LookType {
    case Velocity
    case Forward
}
