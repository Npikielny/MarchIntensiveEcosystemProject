//
//  Matter.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 12/14/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Matter {
    var velocity: SCNVector3
    var acceleration: SCNVector3
    var node: SCNNode
    
    init(Velocity: SCNVector3, Acceleration: SCNVector3, Node: SCNNode) {
        self.velocity = Velocity
        self.acceleration = Acceleration
        self.node = Node
    }
    
}
