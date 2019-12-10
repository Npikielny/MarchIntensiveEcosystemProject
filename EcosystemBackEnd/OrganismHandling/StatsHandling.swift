//
//  StatsHandling.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/22/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Foundation

extension Animal {
    
    func handleStats() {
        if self.hunger > 0 {
            if (self.inProcess == true && self.priority == .Food) == false {
                self.hunger = Float(CGFloat(self.hunger)-((self.node.physicsBody?.velocity.getMagnitude())! * 0.008))
            }
        }else {
            self.hunger = 0
            self.health -= 0.005
        }
        if self.thirst > 0 {
            if (self.inProcess == true && self.priority == .Water) == false {
                self.thirst = Float(CGFloat(self.thirst)-((self.node.physicsBody?.velocity.getMagnitude())! * 0.012))
            }
        }else {
            self.thirst = 0
            self.health -= 0.01
        }
        if self.breedingUrge > 0 {
            self.breedingUrge -= 0.01
        }else {
            self.breedingUrge = 0
        }
    }
    
    func drink() {
        if self.thirst >= 100 {
            self.thirst = 100
            self.inProcess = false
            self.checkPriority()
        }else {
            self.thirst += 0.1
        }
    }
    
    func eat(Item: Food) {
        if Item.foodValue <= 0 {
            Item.eaten()
            self.inProcess = false
            self.checkPriority()
        }else if self.hunger >= 100 {
            self.hunger = 100
            self.inProcess = false
            self.checkPriority()
        }else {
            self.hunger += 0.1
            Item.foodValue -= 0.1
        }
    }
    
}
