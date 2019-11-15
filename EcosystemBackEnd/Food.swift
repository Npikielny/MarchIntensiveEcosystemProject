//
//  Food.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/15/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Food {
    var node: SCNNode
    var foodType: FoodType
    var handler: EnvironmentHandler
    init(Position: SCNVector3, Species: String, foodType: FoodType, Handler: EnvironmentHandler) {
        self.node = getPrefab(Species+".scn", Shaders: nil)
        self.node.name = Species
        self.foodType = foodType
        self.handler = Handler
        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.node, options: [:]))
        self.node.worldPosition = Position
        self.handler.foods.append(self)
        
    }
}

class Apple: Food {
    init(Position: SCNVector3, Handler: EnvironmentHandler) {
        super.init(Position: Position, Species: "apple", foodType: .Fruit, Handler: Handler)
    }
}

enum FoodType {
    case Meat
    case Fruit
}

