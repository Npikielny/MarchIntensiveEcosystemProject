//
//  Food.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/15/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

//class Food: Matter {
//    var foodType: FoodType
//    var foodValue: Float = 50
//    var handler: SimulationBase
//    init(Position: SCNVector3, Species: String, foodType: FoodType, Handler: SimulationBase) {
//        self.foodType = foodType
//        self.handler = Handler
//        if foodType == .Plant {
//            super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: getPrefab(Species+".scn", Shaders: "tree"))
//        }else {
//            super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: getPrefab(Species+".scn", Shaders: nil))
//        }
//        self.node.name = Species
//        self.node.eulerAngles = SCNVector3(0,CGFloat.random(in: 0...CGFloat.pi*2),0)
//
////        self.node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: self.node, options: [:]))
////        self.node.physicsBody?.angularVelocityFactor = SCNVector3().zero()
//        self.node.worldPosition = Position
//        self.handler.foods.append(self)
//
//    }
//
////    func addPhysicsBody() {
////        if let _ = self.node.physicsBody {
////            if self.node.physicsBody?.type == .static {
////                self.node.physicsBody?.type = .dynamic
////                self.node.physicsBody?.velocityFactor = SCNVector3(0, 1, 0)
////            }
////        }
////    }
//
//    func eaten() {
//        handler.foods.removeAll(where: {$0.node.worldPosition == self.node.worldPosition})
//        self.node.removeFromParentNode()
//    }
//
//}
//
//class Apple: Food {
//    init(Position: SCNVector3, Handler: SimulationBase) {
//        super.init(Position: Position, Species: "apple", foodType: .Fruit, Handler: Handler)
//        self.node.scale = SCNVector3(0.5,0.5,0.5)
//
//    }
//}

//class Plant: Food {
//    init(Position: SCNVector3, Handler: SimulationBase, Species: String) {
//        super.init(Position: Position, Species: Species, foodType: .Plant, Handler: Handler)
//        let height = self.node.boundingBox.min.y
//        self.node.worldPosition = self.node.worldPosition.setValue(Component: .y, Value: 2 - height)
//    }
//
//    func reproductionChance() {} //Mark: HUH?
//
//    func setYPosition(plant: Plant) {
//        if plant.node.worldPosition == self.node.worldPosition {
//            plant.node.worldPosition = self.handler.viableVerticies.randomElement()!.vector
//        }else {
//            plant.node.eulerAngles = self.node.eulerAngles
//        }
//    }
//}
//
//class Daisy: Plant {
//    init(Position: SCNVector3, Handler: SimulationBase) {
//        super.init(Position: Position, Handler: Handler, Species: "daisy")
//        self.node.scale = SCNVector3(0.5,0.5,0.5)
//        self.foodValue = 5
//
//    }
//
//    override func reproductionChance() {
//        if Int.random(in: 0..<30*50*30) == 0 {
//            let k = Daisy(Position: self.node.worldPosition+SCNVector3().random().toMagnitude(CGFloat.random(in: 2...6)), Handler: self.handler)
//            setYPosition(plant: k)
//        }
//    }
//}

//class Grass: Plant {
//    init(Position: SCNVector3, Handler: SimulationBase) {
//        super.init(Position: Position, Handler: Handler, Species: "grass")
//        self.foodValue = 10
//    }
//
//    override func reproductionChance() {
//        if Int.random(in: 0..<30*50*10) == 0 {
//            let k = Grass(Position: self.node.worldPosition+SCNVector3().random().toMagnitude(CGFloat.random(in: 4...10)), Handler: self.handler)
//            setYPosition(plant: k)
//        }
//    }
//}



protocol FoodClass {
    static var speciesName: String {get}
    static var foodType: FoodType {get}
    static var maxFoodValue: CGFloat {get}
    static var spawnChance: CGFloat {get}
    static var growthRate: Int {get}
    static var growthDistance: ClosedRange<CGFloat> {get}
    static var scalingFactor: CGFloat {get}
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? {get}
}


struct grass: FoodClass {
    static var speciesName: String = "grass"
    static var foodType: FoodType = .Plant
    static var maxFoodValue: CGFloat = 10
    static var spawnChance: CGFloat = 30 * 25 * 4
    static var growthRate: Int = 30 * 50 * 10
    static var growthDistance: ClosedRange<CGFloat> = 4...10
    static var scalingFactor: CGFloat = 1
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = {return [$0]}
}

struct daisy: FoodClass {
    static var speciesName: String = "daisy"
    static var foodType: FoodType = .Plant
    static var maxFoodValue: CGFloat = 5
    static var spawnChance: CGFloat = 30 * 25 * 4
    static var growthRate: Int = 30*50*30
    static var growthDistance: ClosedRange<CGFloat> = 2...6
    static var scalingFactor: CGFloat = 0.5
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = {return [$0]}
}

struct apple: FoodClass {
    static var speciesName: String = "apple"
    static var foodType: FoodType = .Fruit
    static var maxFoodValue: CGFloat = 50
    static var spawnChance: CGFloat = 30 * 25
    static var growthRate: Int = 0
    static var growthDistance: ClosedRange<CGFloat> = 0...0
    static var scalingFactor: CGFloat = 0.5
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = nil
}

struct cactus: FoodClass {
    static var speciesName: String = "cactus"
    static var foodType: FoodType = .Plant
    static var maxFoodValue: CGFloat = 100
    static var spawnChance: CGFloat = 0
    static var growthRate: Int = 30 * 50 * 10 * 64 * 64
    static var growthDistance: ClosedRange<CGFloat> = 4...10
    static var scalingFactor: CGFloat = 1
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = {let fruit = $0.childNode(withName: "Fruit", recursively: true)!
        return fruit.childNodes
    }
}

class Food: Matter {
    var foodType: FoodType
    var foodValue: Float = 50
    var handler: SimulationBase
    var dataStructure: FoodClass.Type
    
    var foodComponents: [SCNNode]?
    
    init(Position: SCNVector3, DataStructure: FoodClass.Type, Handler: SimulationBase) {
        self.dataStructure = DataStructure
        self.foodType = DataStructure.foodType
        self.handler = Handler
        if foodType == .Plant && DataStructure.speciesName != "cactus" {
            super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: getPrefab(DataStructure.speciesName+".scn", Shaders: "tree"))
        }else {
            super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: getPrefab(DataStructure.speciesName+".scn", Shaders: nil))
        }
        self.node.name = DataStructure.speciesName
        self.node.eulerAngles = SCNVector3(0,CGFloat.random(in: 0...CGFloat.pi*2),0)
        
        self.node.scale = SCNVector3(DataStructure.scalingFactor,DataStructure.scalingFactor,DataStructure.scalingFactor)
        
        self.node.worldPosition = Position
        self.handler.foods.append(self)
        
        if let function = DataStructure.getFoodComponents {
            self.foodComponents = function(self.node)
        }
        if self.dataStructure.foodType == .Plant {
            self.grow()
        }
    }
    
    func reproductionChance() {
        if Int.random(in: 0...dataStructure.growthRate) == 1 {
            var position = self.node.worldPosition + SCNVector3().random().toMagnitude(CGFloat.random(in: dataStructure.growthDistance))
            position = position.setValue(Component: .y, Value: CGFloat(self.handler.gen.valueFor(x: Int32(position.x)/400*128, y: Int32(position.y)/400*128)))
            let function = plantReproductionIndex[self.dataStructure.speciesName]
            let x = function!(position, self.handler)
            x.node.name = "Reproduced"
        }
    }
    
    func grow() {
        for i in self.foodComponents ?? [] {
            i.isHidden = true
        }
        self.node.runAction(SCNAction.scale(by: 1/10, duration: 0), completionHandler: {})
        self.foodValue = 0
        let animation = SCNAction.scale(by: 10, duration: 100)
        self.node.runAction(animation, completionHandler: {
            self.foodValue = Float(self.dataStructure.maxFoodValue)
            for i in self.foodComponents ?? [] {
                self.growFruit(Node: i, Percent: Float(self.dataStructure.maxFoodValue)/Float(self.foodComponents!.count))
            }
        })
    }
    
    func growFruit(Node: SCNNode, Percent: Float) {
        Node.runAction(SCNAction.scale(by: 1/10, duration: 0), completionHandler: {Node.isHidden = false})
        Node.runAction(SCNAction.scale(by: 10, duration: 10), completionHandler: {self.foodValue += Percent})
    }
    
    func setYPosition(plant: Food) {
        if plant.node.worldPosition == self.node.worldPosition {
            plant.node.worldPosition = self.handler.viableVerticies.randomElement()!.vector
        }else {
            plant.node.eulerAngles = self.node.eulerAngles
        }
    }
    
    
    
//    func addPhysicsBody() {
//        if let _ = self.node.physicsBody {
//            if self.node.physicsBody?.type == .static {
//                self.node.physicsBody?.type = .dynamic
//                self.node.physicsBody?.velocityFactor = SCNVector3(0, 1, 0)
//            }
//        }
//    }
    
    func eaten() {
        switch self.dataStructure.foodType {
        case .Fruit:
            handler.foods.removeAll(where: {$0.node.worldPosition == self.node.worldPosition})
            self.node.removeFromParentNode()
        default:
            handler.foods.removeAll(where: {$0.node.worldPosition == self.node.worldPosition})
            self.foodComponents!.forEach({$0.isHidden = true})
        }
    }
    
}

func Apple(Position: SCNVector3, Handler: SimulationBase) -> Food {
    return Food(Position: Position, DataStructure: apple.self, Handler: Handler)
}
func Grass(Position: SCNVector3, Handler: SimulationBase) -> Food {
    return Food(Position: Position, DataStructure: daisy.self, Handler: Handler)
}
func Daisy(Position: SCNVector3, Handler: SimulationBase) -> Food {
    return Food(Position: Position, DataStructure: daisy.self, Handler: Handler)
}
func Cactus(Position: SCNVector3, Handler: SimulationBase) -> Food {
    return Food(Position: Position, DataStructure: cactus.self, Handler: Handler)
}
var plantReproductionIndex: [String: (SCNVector3,SimulationBase) -> Food] = ["apple": Apple, "grass": Grass, "daisy": Daisy,"cactus": Cactus]
