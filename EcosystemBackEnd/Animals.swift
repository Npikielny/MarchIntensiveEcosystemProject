//
//  Animals.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/13/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Rabbit {
    var node: SCNNode
    init(Position: SCNVector3) {
        self.node = getPrefab("rabbit.scn", Shaders: nil)
        self.node.name = "Rabbit"
        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.node, options: [:]))
        self.node.worldPosition = Position
    }
}
