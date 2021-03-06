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
    static var foodEaterType: FoodType {get}
    static var foodGrowthType: FoodType {get}
    static var maxFoodValue: Float {get}
    static var spawnChance: CGFloat {get}
    static var growthRate: Int {get}
    static var growthDistance: ClosedRange<CGFloat> {get}
    static var scalingFactor: CGFloat {get}
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? {get}
    static var timeToGrow: ClosedRange<TimeInterval>? {get}
    static var timeToFruit: ClosedRange<TimeInterval>? {get}
    static var regrowthCount: Int {get}
}


struct grass: FoodClass {
    static var speciesName: String = "grass"
    static var foodEaterType: FoodType = .Plant
    static var foodGrowthType: FoodType = .Plant
    static var maxFoodValue: Float = 10
    static var spawnChance: CGFloat = 30 * 25 * 4
    static var growthRate: Int = 30 * 50 * 10
    static var growthDistance: ClosedRange<CGFloat> = 4...10
    static var scalingFactor: CGFloat = 1
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = {return [$0]}
    static var timeToGrow: ClosedRange<TimeInterval>? = 50...70
    static var timeToFruit: ClosedRange<TimeInterval>? = 50...70
    static var regrowthCount: Int = 5
}

struct daisy: FoodClass {
    static var speciesName: String = "daisy"
    static var foodEaterType: FoodType = .Plant
    static var foodGrowthType: FoodType = .Plant
    static var maxFoodValue: Float = 5
    static var spawnChance: CGFloat = 30 * 25 * 4
    static var growthRate: Int = 30*50*30
    static var growthDistance: ClosedRange<CGFloat> = 2...6
    static var scalingFactor: CGFloat = 0.5
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = {return [$0]}
    static var timeToGrow: ClosedRange<TimeInterval>? = 40...60
    static var timeToFruit: ClosedRange<TimeInterval>? = 40...60
    static var regrowthCount: Int = 3
}

struct apple: FoodClass {
    static var speciesName: String = "apple"
    static var foodEaterType: FoodType = .Fruit
    static var foodGrowthType: FoodType = .Fruit
    static var maxFoodValue: Float = 50
    static var spawnChance: CGFloat = 30 * 25
    static var growthRate: Int = 0
    static var growthDistance: ClosedRange<CGFloat> = 0...0
    static var scalingFactor: CGFloat = 0.5
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = nil
    static var timeToGrow: ClosedRange<TimeInterval>? = nil
    static var timeToFruit: ClosedRange<TimeInterval>? = nil
    static var regrowthCount: Int = 0
}

struct cactus: FoodClass {
    static var speciesName: String = "cactus"
    static var foodEaterType: FoodType = .Fruit
    static var foodGrowthType: FoodType = .Producer
    static var maxFoodValue: Float = 100
    static var spawnChance: CGFloat = 0
    static var growthRate: Int = 30 * 50 * 10 * 64 * 64
    static var growthDistance: ClosedRange<CGFloat> = 4...10
    static var scalingFactor: CGFloat = 1
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = {let fruit = $0.childNode(withName: "Fruit", recursively: true)!; return fruit.childNodes}
    static var timeToGrow: ClosedRange<TimeInterval>? = 150...200
    static var timeToFruit: ClosedRange<TimeInterval>? = 90...120
    static var regrowthCount: Int = 7
}

struct berryBush: FoodClass {
    static var speciesName: String = "blueberryBush"
    static var foodEaterType: FoodType = .Fruit
    static var foodGrowthType: FoodType = .Producer
    static var maxFoodValue: Float = 10
    static var spawnChance: CGFloat = 30 * 50 * 10 * 30 * 50 * 10
    static var growthRate: Int = 30 * 50 * 10 * 64
    static var growthDistance: ClosedRange<CGFloat> = 2...6
    static var scalingFactor: CGFloat = 1
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = {let fruit = $0.childNode(withName: "Fruit", recursively: true)!; return fruit.childNodes}
    static var timeToGrow: ClosedRange<TimeInterval>? = 75...100
    static var timeToFruit: ClosedRange<TimeInterval>? = 45...60
    static var regrowthCount: Int = 9
    
}

struct meat: FoodClass {
    static var speciesName: String = "meat"
    static var foodEaterType: FoodType = .Meat
    static var foodGrowthType: FoodType = .Meat
    static var maxFoodValue: Float = 50
    static var spawnChance: CGFloat = 0
    static var growthRate: Int = 0
    static var growthDistance: ClosedRange<CGFloat> = 0...0
    static var scalingFactor: CGFloat = 0.5
    static var getFoodComponents: ((SCNNode) -> [SCNNode])? = nil
    static var timeToGrow: ClosedRange<TimeInterval>? = nil
    static var timeToFruit: ClosedRange<TimeInterval>? = nil
    static var regrowthCount: Int = 0
}

class Food: Matter {
    var foodGrowthType: FoodType
    var foodEaterType: FoodType
    var foodValue: Float = 0
    var handler: EnvironmentHandler
    var dataStructure: FoodClass.Type
    
    var foodComponents: [SCNNode]?
    var regrown: Int = 0
    
    init(Position: SCNVector3, DataStructure: FoodClass.Type, Handler: EnvironmentHandler) {
        self.dataStructure = DataStructure
        self.foodGrowthType = DataStructure.foodGrowthType
        self.foodEaterType = DataStructure.foodEaterType
        self.handler = Handler
        if foodGrowthType == .Plant {
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
        
        switch self.dataStructure.foodGrowthType {
        case .Producer:
            self.grow()
        case .Plant:
            self.foodComponents?.forEach({growFruit(Node: $0, Percent: Float(self.dataStructure.maxFoodValue)/Float(self.foodComponents!.count))})
        default:
            self.foodValue = Float(self.dataStructure.maxFoodValue)
        }
    }
    
    func reproductionChance() {
        if Int.random(in: 0...dataStructure.growthRate) == 1 {
            var position = self.node.worldPosition + SCNVector3().random().toMagnitude(CGFloat.random(in: dataStructure.growthDistance))
            position = position.setValue(Component: .y, Value: CGFloat(self.handler.mapValueAt(position)))
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
        let animation = SCNAction.scale(by: 10, duration: TimeInterval.random(in: self.dataStructure.timeToGrow!))
        self.node.runAction(animation, completionHandler: {
            for i in self.foodComponents ?? [] {
                self.growFruit(Node: i, Percent: Float(self.dataStructure.maxFoodValue)/Float(self.foodComponents!.count))
            }
        })
    }

    func growFruit(Node: SCNNode, Percent: Float) {
        Node.runAction(SCNAction.scale(by: 1/10, duration: 0), completionHandler: {Node.isHidden = false})
        Node.runAction(SCNAction.scale(by: 10, duration: TimeInterval.random(in: self.dataStructure.timeToFruit!)), completionHandler: {self.foodValue += Percent})
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
        self.regrown += 1
        let removeItem = {
            self.handler.foods.removeAll(where: {$0.node == self.node})
            self.node.removeFromParentNode()
        }
        switch self.dataStructure.foodGrowthType {
        case .Fruit:
            removeItem()
        case .Meat:
            removeItem()
        default:
            if self.regrown >= self.dataStructure.regrowthCount {
                removeItem()
            }else {
                self.foodComponents!.forEach({$0.isHidden = true})
                self.foodComponents!.forEach({growFruit(Node: $0, Percent: Float(self.dataStructure.maxFoodValue) / Float(self.foodComponents!.count))})
            }
        }
    }
    
}

func Apple(Position: SCNVector3, Handler: EnvironmentHandler) -> Food {
    return Food(Position: Position, DataStructure: apple.self, Handler: Handler)
}
func Grass(Position: SCNVector3, Handler: EnvironmentHandler) -> Food {
    return Food(Position: Position, DataStructure: grass.self, Handler: Handler)
}
func Daisy(Position: SCNVector3, Handler: EnvironmentHandler) -> Food {
    return Food(Position: Position, DataStructure: daisy.self, Handler: Handler)
}
func Cactus(Position: SCNVector3, Handler: EnvironmentHandler) -> Food {
    return Food(Position: Position, DataStructure: cactus.self, Handler: Handler)
}
func BerryBush(Position: SCNVector3, Handler: EnvironmentHandler) -> Food {
    return Food(Position: Position, DataStructure: berryBush.self, Handler: Handler)
}
func Meat(Position: SCNVector3, Handler: EnvironmentHandler) -> Food {
    return Food(Position: Position, DataStructure: meat.self, Handler: Handler)
}

var plantReproductionIndex: [String: (SCNVector3,EnvironmentHandler) -> Food] = ["apple": Apple, "grass": Grass, "daisy": Daisy,"cactus": Cactus,"blueberryBush":BerryBush]
