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
    var hunger: Float
    var thirst: Float
    var health: Float {
        didSet {
            if self.health <= 0 {
                self.die()
            }
        }
    }
    var breedingUrge: Float
    
    var maxhunger: Float {
        didSet {
            self.hunger = maxhunger
        }
    }
    var maxthirst: Float {
        didSet {
            self.thirst = maxthirst
        }
    }
    var maxhealth: Float {
        didSet {
            self.health = maxhealth
        }
    }
    var maxbreedingUrge: Float {
        didSet {
            self.breedingUrge = maxbreedingUrge
        }
    }
    
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
    
//
//    init(Position: SCNVector3, Species: String, lookType: LookType, Handler: SimulationBase) {
//        let model = getPrefab(Species+".scn", Shaders: nil)
//        self.height = model.boundingBox.max.y-model.boundingBox.min.y
//        self.lookType = lookType
//        self.handler = Handler
//        self.Id = Int32(handler.animals.count)
//        super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: model)
//        self.node.name = Handler.Names.randomElement()
//        additionalSetup()
//        self.node.worldPosition = Position
//        self.handler.animals.append(self)
//    }
//
    var move: (Animal) -> ()
    
    var speciesData: AnimalClass.Type
    
    init(SpeciesStats: AnimalClass.Type, Position: SCNVector3, Handler: SimulationBase) {
        self.speciesData = SpeciesStats
        self.hunger = 100
        self.thirst = 100
        self.breedingUrge = 100
        self.health = 100
        
        let model = getPrefab(SpeciesStats.name+".scn", Shaders: nil)
        self.height = model.boundingBox.max.y-model.boundingBox.min.y
        self.lookType = SpeciesStats.lookType
        self.handler = Handler
        self.Id = Int32(handler.animals.count)
        
        self.maxhunger = SpeciesStats.maxHunger
        self.maxthirst = SpeciesStats.maxThirst
        self.maxhealth = SpeciesStats.maxHealth
        self.maxbreedingUrge = SpeciesStats.maxBreedingUrge
        
        self.move = SpeciesStats.movementFunction
        
        super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: model)
        self.node.name = Handler.Names.randomElement()
        additionalSetup()
        self.node.worldPosition = Position
        self.handler.animals.append(self)
        
        self.target = self.node.worldPosition.setValue(Component: .y, Value: handler.mapValueAt(self.node.worldPosition))
        
    }
//
//    init(DebugInit: EnvironmentHandler) {
//        self.height = 0.2
//        self.lookType = .Velocity
//        self.handler = DebugInit
////        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.node, options: [:]))
////        self.node.physicsBody?.angularVelocityFactor = SCNVector3().zero()
//        self.Id = Int32(DebugInit.animals.count)
//        super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: SCNNode(geometry: SCNSphere(radius: 0.1)))
//        additionalSetup()
//        self.node.worldPosition = SCNVector3().initOfComponent(Component: .y, Value: 10)
//        self.handler.animals.append(self)
//
//    }
    
    func die() {
        if dead == false {
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
        
    }
    
    func additionalPhysics() {
        //Customizeable Function Run on Physics Render
    }
    
    func additionalSetup() {
        
    }
    
    func breedRequest(_ Partner: Animal) {
        if self.hunger > 30 && self.thirst > 30 && self.breedingUrge < 70 {
            if let _ = self.targetMate {
                Partner.targetMate = nil
            }else {
                self.targetMate = Partner
                Partner.targetMate = self
                self.priority = .Breed
                let target = (self.node.worldPosition + Partner.node.worldPosition).scalarMultiplication(Scalar: 0.5)
                self.target = target
                Partner.target = target
            }
        }else {
            self.targetMate = nil
            Partner.targetMate = nil
        }
    }
    
}


protocol AnimalClass {
    static var lookType: LookType {get}
    static var maxHunger: Float {get}
    static var maxThirst: Float {get}
    static var maxHealth: Float {get}
    static var maxBreedingUrge: Float {get}
    static var Speed: CGFloat {get}
    static var species: Species {get}
    static var foodType: FoodType {get}
    static var name: String {get}
    static var movementFunction : (Animal) -> () {get}
}

struct rabbit: AnimalClass {
    static var lookType: LookType = .Forward
    static var maxHunger: Float = 100
    static var maxThirst: Float = 100
    static var maxHealth: Float = 100
    static var maxBreedingUrge: Float = 100
    static var Speed: CGFloat = 2
    static var species: Species = .Rabbit
    static var foodType: FoodType = .Vegetarian
    static var name: String = "rabbit"
    static var movementFunction: (Animal) -> () = {
        let h = $0.handler.mapValueAt($0.node.worldPosition)
        if ($0.velocity.zero(.y)).getMagnitude() == 0 {
            let distance = ($0.target - $0.node.worldPosition).zero(.y).getMagnitude()
            if distance <= $0.Speed {
                let velocity = pow(abs(9.807)*distance,0.5)
                $0.velocity = ($0.target - $0.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
            }else {
                let velocity = pow(abs(9.807)*$0.Speed,0.5)
                $0.velocity = ($0.target - $0.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
            }
        }
        
    }
}

struct fox: AnimalClass {
    static var lookType: LookType = .Forward
    static var maxHunger: Float = 500
    static var maxThirst: Float = 500
    static var maxHealth: Float = 500
    static var maxBreedingUrge: Float = 500
    static var Speed: CGFloat = 2
    static var species: Species = .Fox
    static var foodType: FoodType = .Meat
    static var name: String = "fox"
    static var movementFunction: (Animal) -> () = {
        let h = $0.handler.gen.valueFor(x: Int32($0.node.worldPosition.x / 400) * 128, y: Int32($0.node.worldPosition.z / 400) * 128)
        if abs(CGFloat(h) - $0.node.worldPosition.y) < 0.1 || $0.node.worldPosition.y <= CGFloat(h) {
            $0.node.worldPosition = $0.node.worldPosition.setValue(Component: .y, Value: CGFloat(h))
            
            if ($0.velocity.zero(.y)).getMagnitude() <= 0.01 {
                let distance = ($0.target - $0.node.worldPosition).zero(.y).getMagnitude()
                if distance <= $0.Speed {
                    if distance < 1.2 {
                        $0.node.worldPosition = $0.target
                    }else {
                        let velocity = pow(abs(1)*distance,0.5)
                        $0.velocity = ($0.target - $0.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
                    }
                }else {
                    let velocity = pow(abs(1)*$0.Speed,0.5)
                    $0.velocity = ($0.target - $0.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
                }
            }
            
        }
    }
}

func Rabbit(Position: SCNVector3, Handler: SimulationBase) -> Animal {
    return Animal(SpeciesStats: rabbit.self, Position: Position, Handler: Handler)
}

func Fox(Position: SCNVector3, Handler: SimulationBase) -> Animal {
    return Animal(SpeciesStats: fox.self, Position: Position, Handler: Handler)
}




//
//class Rabbit: Animal {
//    init(Position: SCNVector3, Handler: SimulationBase) {
//        super.init(Position: Position, Species: "rabbit", lookType: .Forward, Handler: Handler)
//        self.target = self.node.worldPosition
//        self.Speed = 2
//    }
//
//    override func move() {
//        if (self.velocity.zero(.y)).getMagnitude() <= 0.01 {
//            let distance = (self.target - self.node.worldPosition).zero(.y).getMagnitude()
//            if distance <= self.Speed {
//                if distance < 1.2 {
//                    self.node.worldPosition = self.target
//                }else {
//                    let velocity = pow(abs(1)*distance,0.5)
//                    self.velocity = (self.target - self.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
//                }
//            }else {
//                let velocity = pow(abs(1)*self.Speed,0.5)
//                self.velocity = (self.target - self.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
//            }
//        }
//    }
//
//    var targetNode: SCNNode = {
//        let node = SCNNode(geometry: SCNSphere(radius: 0.1))
//        node.geometry?.materials.first?.diffuse.contents = NSColor.cyan
//        return node
//    }()
//
//    var isSelected: Bool = false
//
//    override func additionalPhysics() {
//    }
//
//    override func additionalSetup() {
////        self.node.physicsBody?.friction = 1
////        self.handler.Scene.rootNode.addChildNode(self.targetNode)
////        self.handler.Scene.rootNode.addChildNode(self.thirstNode)
////        self.handler.Scene.rootNode.addChildNode(self.hungerNode)
////        self.handler.Scene.rootNode.addChildNode(self.healthNode)
////        self.handler.Scene.rootNode.addChildNode(self.statsNode)
//    }
//
//}
//
//class debugger: Animal {
//
//    init(Handler: EnvironmentHandler) {
//        super.init(DebugInit: Handler)
//        Handler.Scene.rootNode.addChildNode(self.targetNode)
//
//    }
//
//    var targetNode: SCNNode = {
//        let node = SCNNode(geometry: SCNSphere(radius: 0.1))
//        node.geometry?.materials.first?.diffuse.contents = NSColor.cyan
//        return node
//    }()
//
//    override func additionalPhysics() {
//        self.targetNode.worldPosition = self.target
//    }
//
//}
//
//class Fox: Animal {
//    init(Position: SCNVector3, Handler: SimulationBase) {
//        super.init(Position: Position, Species: "fox", lookType: .Forward, Handler: Handler)
//        self.target = self.node.worldPosition
//        self.Speed = 5
//    }
//
//    override func move() {
//        if (self.velocity.zero(.y)).getMagnitude() <= 0.01 {
//            let distance = (self.target - self.node.worldPosition).zero(.y).getMagnitude()
//            if distance <= self.Speed {
//                if distance < 1.2 {
//                    self.node.worldPosition = self.target
//                }else {
//                    let velocity = pow(abs(1)*distance,0.5)
//                    self.velocity = (self.target - self.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
//                }
//            }else {
//                let velocity = pow(abs(1)*self.Speed,0.5)
//                self.velocity = (self.target - self.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
//            }
//        }
//    }
//
//    var targetNode: SCNNode = {
//        let node = SCNNode(geometry: SCNSphere(radius: 0.1))
//        node.geometry?.materials.first?.diffuse.contents = NSColor.cyan
//        return node
//    }()
//
//    var isSelected: Bool = false
//
//    override func additionalPhysics() {
//    }
//
//    override func additionalSetup() {
////        self.node.physicsBody?.friction = 1
////        self.handler.Scene.rootNode.addChildNode(self.targetNode)
////        self.handler.Scene.rootNode.addChildNode(self.thirstNode)
////        self.handler.Scene.rootNode.addChildNode(self.hungerNode)
////        self.handler.Scene.rootNode.addChildNode(self.healthNode)
////        self.handler.Scene.rootNode.addChildNode(self.statsNode)
//    }
//
//}

enum Species {
    case Rabbit
    case Fox
}

enum Sex {
    case Male
    case Female
}
