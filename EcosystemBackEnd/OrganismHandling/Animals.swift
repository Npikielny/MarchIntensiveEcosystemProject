//
//  Animals.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/13/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Animal {
    var height: CGFloat
    
    var node: SCNNode
    //Species Traits
    var lookType: LookType
    var handler: EnvironmentHandler
    //Priority Handling
    var hunger: Float = 100
    var thirst: Float = 100
    var health: Float = 100
    var breedingUrge: Float = 100
    var priority: Priority = .Idle
    //Life Handling
    var age: Float = 0
    var dead: Bool = false
    var inProcess: Bool = false
    var velocity: SCNVector3 = SCNVector3().zero()
    var Id: Int32
    //Movement
    var target: SCNVector3 = SCNVector3().zero()
    func getHeight() -> CGFloat {return self.node.worldPosition.y-(self.node.boundingBox.min.y)/2}
    
    //Individual Traits
    var Speed: CGFloat = 2
    
    lazy var priorities: () -> [(Priority,Float)] = {return [(.Food,self.hunger), (.Water,self.thirst), (.Breed,self.breedingUrge)]}
    
    
    init(Position: SCNVector3, Species: String, lookType: LookType, Handler: EnvironmentHandler) {
        let model = getPrefab(Species+".scn", Shaders: nil)
        self.node = model
        self.height = model.boundingBox.max.y-model.boundingBox.min.y
        self.node.name = Handler.Names.randomElement()
        self.lookType = lookType
        self.handler = Handler
        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.node, options: [:]))
        self.node.physicsBody?.angularVelocityFactor = SCNVector3().zero()
        self.Id = Int32(handler.animals.count)
        additionalSetup()
        self.node.worldPosition = Position
        self.handler.animals.append(self)
        
    }
    
    init(DebugInit: EnvironmentHandler) {
        self.node = SCNNode(geometry: SCNSphere(radius: 0.1))
        self.height = 0.2
        self.lookType = .Velocity
        self.handler = DebugInit
        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.node, options: [:]))
        self.node.physicsBody?.angularVelocityFactor = SCNVector3().zero()
        self.Id = Int32(DebugInit.animals.count)
        additionalSetup()
        self.node.worldPosition = SCNVector3().initOfComponent(Component: .y, Value: 10)
        self.handler.animals.append(self)
        
    }
    
    func die() {
        dead = true
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: CGFloat(2 * Float.pi)/4))
        spin.duration = 10
        self.node.addAnimation(spin, forKey: "rotation")
        
    }
    
    func additionalPhysics() {
        //Customizeable Function Run on Physics Render
    }
    
    func additionalSetup() {
        
    }
    
    func move() {
        self.node.physicsBody?.velocity += ((self.target-self.node.worldPosition).unitVector()-self.node.physicsBody!.velocity.unitVector()).toMagnitude(self.Speed/16)
        self.node.physicsBody?.velocity = (self.node.physicsBody?.velocity.clampPartialMagnitude(Excluding: .y, Min: 0, Max: self.Speed))!
    }
    
}

class Rabbit: Animal {
    init(Position: SCNVector3, Handler: EnvironmentHandler) {
        super.init(Position: Position, Species: "rabbit", lookType: .Forward, Handler: Handler)
        self.target = self.node.worldPosition
    }
    
    override func move() {
        if (self.node.physicsBody?.velocity.zero(.y))!.getMagnitude() <= 0.01 {
            let distance = (self.target - self.node.worldPosition).zero(.y).getMagnitude()
            if distance <= self.Speed {
                if distance < 1.2 {
                    self.node.worldPosition = self.target
                }else {
                    let velocity = pow(abs(self.handler.Scene.physicsWorld.gravity.y)*distance,0.5)
                    self.node.physicsBody?.velocity = (self.target - self.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
                }
            }else {
                let velocity = pow(abs(self.handler.Scene.physicsWorld.gravity.y)*self.Speed,0.5)
                self.node.physicsBody?.velocity = (self.target - self.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
            }
        }
    }
    
    var targetNode: SCNNode = {
        let node = SCNNode(geometry: SCNSphere(radius: 0.1))
        node.geometry?.materials.first?.diffuse.contents = NSColor.cyan
        return node
    }()
    
    var isSelected: Bool = false
    
    override func additionalPhysics() {
    }
    
    override func additionalSetup() {
        self.node.physicsBody?.friction = 1
//        self.handler.Scene.rootNode.addChildNode(self.targetNode)
//        self.handler.Scene.rootNode.addChildNode(self.thirstNode)
//        self.handler.Scene.rootNode.addChildNode(self.hungerNode)
//        self.handler.Scene.rootNode.addChildNode(self.healthNode)
//        self.handler.Scene.rootNode.addChildNode(self.statsNode)
    }
    
}

class debugger: Animal {
    
    init(Handler: EnvironmentHandler) {
        super.init(DebugInit: Handler)
        Handler.Scene.rootNode.addChildNode(self.targetNode)
        
    }
    
    var targetNode: SCNNode = {
        let node = SCNNode(geometry: SCNSphere(radius: 0.1))
        node.geometry?.materials.first?.diffuse.contents = NSColor.cyan
        return node
    }()
    
    override func additionalPhysics() {
        self.targetNode.worldPosition = self.target
    }
    
}
