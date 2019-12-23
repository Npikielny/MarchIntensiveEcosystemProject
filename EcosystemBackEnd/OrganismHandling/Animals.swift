//
//  Animals.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/13/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Animal: Matter {
    var height: CGFloat
    
    //Species Traits
    var lookType: LookType
    var handler: SimulationBase
    //Priority Handling
    var hunger: Float = 100
    var thirst: Float = 100
    var health: Float = 100 {
        didSet {
            if self.health <= 0 {
                self.die()
            }
        }
    }
    var breedingUrge: Float = 100
    var priority: Priority = .Idle
    //Life Handling
    var age: Float = 0
    var sex: Sex = {
        if Int.random(in: 0...1) == 0 {
            return .Male
        }else {
            return .Female
        }
    }()
    var dead: Bool = false
    var inProcess: Bool = false
    var Id: Int32
    //Movement
    var target: SCNVector3 = SCNVector3().zero()
    func getHeight() -> CGFloat {return self.node.worldPosition.y-(self.node.boundingBox.min.y)/2}
    var targetMate: Animal?
    var targetFood: Food?
    //Individual Traits
    var Speed: CGFloat = 2
    
    
    
    lazy var priorities: () -> [(Priority,Float)] = {return [(.Food,self.hunger), (.Water,self.thirst), (.Breed,self.breedingUrge)]}
    
    
    init(Position: SCNVector3, Species: String, lookType: LookType, Handler: SimulationBase) {
        let model = getPrefab(Species+".scn", Shaders: nil)
        self.height = model.boundingBox.max.y-model.boundingBox.min.y
        self.lookType = lookType
        self.handler = Handler
        self.Id = Int32(handler.animals.count)
        super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: model)
        self.node.name = Handler.Names.randomElement()
        additionalSetup()
        self.node.worldPosition = Position
        self.handler.animals.append(self)
    }
    
    init(DebugInit: EnvironmentHandler) {
        self.height = 0.2
        self.lookType = .Velocity
        self.handler = DebugInit
//        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.node, options: [:]))
//        self.node.physicsBody?.angularVelocityFactor = SCNVector3().zero()
        self.Id = Int32(DebugInit.animals.count)
        super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: SCNNode(geometry: SCNSphere(radius: 0.1)))
        additionalSetup()
        self.node.worldPosition = SCNVector3().initOfComponent(Component: .y, Value: 10)
        self.handler.animals.append(self)
        
    }
    
    func die() {
        dead = true
//        let spin = CABasicAnimation(keyPath: "rotation")
//        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: 0))
//        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: CGFloat(2 * Float.pi)/4))
//        spin.duration = 10
//        self.node.addAnimation(spin, forKey: "rotation")
        let action = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi/4, duration: 1)
        self.node.runAction(action, completionHandler: {
            self.handler.animals.removeAll(where: {$0.node == self.node})
            self.node.removeFromParentNode()
        })
        
    }
    
    func additionalPhysics() {
        //Customizeable Function Run on Physics Render
    }
    
    func additionalSetup() {
        
    }
    
    func move() {
//        self.node.physicsBody?.velocity += ((self.target-self.node.worldPosition).unitVector()-self.node.physicsBody!.velocity.unitVector()).toMagnitude(self.Speed/16)
//        self.node.physicsBody?.velocity = (self.node.physicsBody?.velocity.clampPartialMagnitude(Excluding: .y, Min: 0, Max: self.Speed))!
    }
    
    func breedRequest(_ Partner: Animal) {
        if self.hunger > 30 && self.thirst > 30 {
            if let _ = self.targetMate {
            }else {
                self.targetMate = Partner
                Partner.targetMate = self
                self.priority = .Breed
                let target = (self.node.worldPosition + Partner.node.worldPosition).scalarMultiplication(Scalar: 0.5)
                self.target = target
                Partner.target = target
            }
        }else {
        }
    }
    
}

class Rabbit: Animal {
    init(Position: SCNVector3, Handler: SimulationBase) {
        super.init(Position: Position, Species: "rabbit", lookType: .Velocity, Handler: Handler)
        self.target = self.node.worldPosition
    }
    
    override func move() {
        if (self.velocity.zero(.y)).getMagnitude() <= 0.01 {
            let distance = (self.target - self.node.worldPosition).zero(.y).getMagnitude()
            if distance <= self.Speed {
                if distance < 1.2 {
                    self.node.worldPosition = self.target
                }else {
                    let velocity = pow(abs(1)*distance,0.5)
                    self.velocity = (self.target - self.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
                }
            }else {
                let velocity = pow(abs(1)*self.Speed,0.5)
                self.velocity = (self.target - self.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
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
//        self.node.physicsBody?.friction = 1
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

enum Sex {
    case Male
    case Female
}
