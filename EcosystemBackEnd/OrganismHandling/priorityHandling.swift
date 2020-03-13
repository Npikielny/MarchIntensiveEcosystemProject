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
        var priority = self.priorities().sorted(by: {$0.1 < $1.1})
        priority.removeAll(where: {self.barring.contains($0.0)})
        
        if priority.first!.1 > 50 {
            let bestPriority: Priority = {
                var validPriorities = priority
                validPriorities.removeAll(where: {$0.0 == .Breed})
                for i in validPriorities {
                    if (i.2 - i.1)/i.2 >= 0.25 {
                        return i.0
                    }
                }
                return .Idle
            }()
            self.priority = bestPriority
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
    case Producer
    case Omnivore
    case Vegetarian
}

var foodConversion: [FoodType:[FoodType]] = [.Meat: [.Meat], .Fruit: [.Fruit], .Plant: [.Plant], .Omnivore: [.Meat,.Fruit,.Plant], .Vegetarian: [.Fruit, .Plant]]

