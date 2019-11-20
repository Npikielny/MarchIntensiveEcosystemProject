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
        let priority = self.priorities().sorted(by: {$0.1>$1.1}).first!
        if priority.1 < 50 {
            self.priority = .Idle
        }else {
            self.priority = priority.0
        }
    }
    
    func setMovement() {
        switch self.priority {
        case .Food:
            print("E")
        case .Water:
            print("E")
        case .Breed:
            print("E")
        case .Idle:
            print("E")
        case .Flee:
            print("E")
        default:
            print("E")
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
}

