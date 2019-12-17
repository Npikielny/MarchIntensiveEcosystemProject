//
//  StatsHandling.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/22/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

extension Animal {
    
    func handleStats() {
        if self.inProcess == false {
            if self.hunger > 0 {
                if (self.inProcess == true && self.priority == .Food) == false {
                    self.hunger = Float(CGFloat(self.hunger)-((self.velocity.getMagnitude()) * 0.008))
                    self.hunger -= 0.0001
                }
            }else {
                self.hunger = 0
                self.health -= 0.01
            }
            if self.thirst > 0 {
                if (self.inProcess == true && self.priority == .Water) == false {
                    self.thirst = Float(CGFloat(self.thirst)-((self.velocity.getMagnitude()) * 0.012))
                    self.thirst -= 0.0001
                }
            }else {
                self.thirst = 0
                self.health -= 0.01
            }
            if self.breedingUrge > 0 {
                self.breedingUrge -= Float.random(in: 0.002...0.02)
            }else {
                self.breedingUrge = 0
            }
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
    
    func breed() {
        self.breedingUrge += 0.1
        if self.velocity.y == 0 && bottom(self) - 2 < 0.8 {
            self.velocity = SCNVector3(0,2,0)
        }
        
        if self.breedingUrge >= 100 {
            birth()
            self.inProcess = false
            self.targetMate!.birth()
            self.targetMate!.inProcess = false
            self.checkPriority()
            self.targetMate?.checkPriority()
            self.targetMate?.targetMate = nil
            self.targetMate = nil
        }
    }
    
    func birth() {
        for _ in 0...3 {
            if Int.random(in: 0...1) == 0 {
                _ = Rabbit(Position: self.node.worldPosition, Handler: self.handler)
            }
        }
    }
    
}
