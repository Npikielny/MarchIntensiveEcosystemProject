//
//  priorityHandling.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/20/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

extension Animal {
    
    func checkPriority () {
        let priority = self.priorities().sorted(by: {$0.1<$1.1})
        if priority.first!.1 > 50 {
            self.priority = .Idle
        }else {
            if priority.first!.0 == .Breed {
                if priority[1].1 < 30 {//Making sure food/water is prioritized over breeding
                    self.priority = priority[1].0
                }else {
                    self.priority = priority.first!.0
                }
            }else {
                self.priority = priority.first!.0
            }
        }
    }
    
}

enum Priority {
    case Food
    case Water
    case Breed
    case Idle
    case Flee
}


enum FoodType {
    case Meat
    case Fruit
    case Plant
    case Omnivore
    case Vegetarian
}

var foodConversion: [FoodType:[FoodType]] = [.Meat: [.Meat], .Fruit: [.Fruit], .Plant: [.Plant], .Omnivore: [.Meat,.Fruit,.Plant], .Vegetarian: [.Fruit, .Plant]]

