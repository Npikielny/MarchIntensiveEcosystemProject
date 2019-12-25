//
//  Food.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/15/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Food: Matter {
    var foodType: FoodType
    var foodValue: Float = 50
    var handler: SimulationBase
    init(Position: SCNVector3, Species: String, foodType: FoodType, Handler: SimulationBase) {
        self.foodType = foodType
        self.handler = Handler
        if foodType == .Plant {
            super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: getPrefab(Species+".scn", Shaders: "tree"))
        }else {
            super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: getPrefab(Species+".scn", Shaders: nil))
        }
        self.node.name = Species
        self.node.eulerAngles = SCNVector3(0,CGFloat.random(in: 0...CGFloat.pi*2),0)
        
//        self.node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: self.node, options: [:]))
//        self.node.physicsBody?.angularVelocityFactor = SCNVector3().zero()
        self.node.worldPosition = Position
        self.handler.foods.append(self)
        
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
        handler.foods.removeAll(where: {$0.node.worldPosition == self.node.worldPosition})
        self.node.removeFromParentNode()
    }
    
}

class Apple: Food {
    init(Position: SCNVector3, Handler: SimulationBase) {
        super.init(Position: Position, Species: "apple", foodType: .Fruit, Handler: Handler)
        self.node.scale = SCNVector3(0.5,0.5,0.5)
        
    }
}

class Plant: Food {
    init(Position: SCNVector3, Handler: SimulationBase, Species: String) {
        super.init(Position: Position, Species: Species, foodType: .Plant, Handler: Handler)
    }
    
    func reproductionChance() {}
    func setYPosition(plant: Plant) {
        let height = plant.node.boundingBox.min.y
        plant.node.worldPosition = self.node.worldPosition.setValue(Component: .y, Value: 2 - height)
        if plant.node.worldPosition == self.node.worldPosition {
            plant.node.worldPosition = self.handler.viableVerticies.randomElement()!.vector
        }else {
            plant.node.eulerAngles = self.node.eulerAngles
        }
    }
}

class Daisy: Plant {
    init(Position: SCNVector3, Handler: SimulationBase) {
        super.init(Position: Position, Handler: Handler, Species: "daisy")
        self.node.scale = SCNVector3(0.5,0.5,0.5)
        self.foodValue = 5
        
    }
    
    override func reproductionChance() {
        if Int.random(in: 0..<30*50*30) == 0 {
            let k = Daisy(Position: self.node.worldPosition+SCNVector3().random().toMagnitude(CGFloat.random(in: 2...6)), Handler: self.handler)
            setYPosition(plant: k)
        }
    }
}

class Grass: Plant {
    init(Position: SCNVector3, Handler: SimulationBase) {
        super.init(Position: Position, Handler: Handler, Species: "grass")
        self.foodValue = 10
    }
    
    override func reproductionChance() {
        if Int.random(in: 0..<30*50*10) == 0 {
            let k = Grass(Position: self.node.worldPosition+SCNVector3().random().toMagnitude(CGFloat.random(in: 4...10)), Handler: self.handler)
            setYPosition(plant: k)
        }
    }
}
