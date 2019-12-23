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
        self.age += 0.001
        self.Speed = CGFloat(3/(1 + pow(2.18,0.1*(self.age-15))))
        let ageMultiplier: Float = 1 + pow(2.18,-0.3*(self.age-6))
        if self.hunger > 0 {
            if (self.inProcess == true && self.priority == .Food) == false {
                self.hunger = Float(CGFloat(self.hunger)-((self.velocity.getMagnitude()) * CGFloat(ageMultiplier) * 0.0018*2))
                self.hunger -= 0.0001
            }
        }else {
            self.hunger = 0
            self.health -= ageMultiplier * 0.025 * self.age/6
        }
        if self.thirst > 0 {
            if (self.inProcess == true && self.priority == .Water) == false {
                self.thirst = Float(CGFloat(self.thirst)-((self.velocity.getMagnitude()) * CGFloat(ageMultiplier) * 0.0027*2))
                self.thirst -= 0.0001
            }
        }else {
            self.thirst = 0
            self.health -= ageMultiplier * 0.025 * self.age/6
        }
        if self.breedingUrge > 0 {
            if self.age >= 3 {
//                    self.breedingUrge -= cos((self.age-6)*Float.pi/12)*Float.pi/12*0.03
                self.breedingUrge -= Float.random(in: 0.004...0.04)
//                    self.breedingUrge = 0
            }
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
    
    func eat(Item: inout Food) -> Bool {
        if Item.foodValue <= 0 {
            Item.eaten()
            self.inProcess = false
            self.checkPriority()
            return true
        }else if self.hunger >= 100 {
            self.inProcess = false
            self.checkPriority()
            return true
        }else {
            self.hunger += 0.1
            Item.foodValue -= 0.1
            return false
        }
    }
    
    func breed() {
        self.breedingUrge += 0.1
        if self.velocity.y == 0 && bottom(self) - 2 < 0.8 {
            self.velocity = SCNVector3(0,2,0)
        }
        
        if self.breedingUrge >= 100 {
            self.breedingUrge = 100
            self.targetMate?.breedingUrge = 100
            if self.targetMate!.sex == .Female {
            self.targetMate!.birth()
            }else {
                birth()
            }
            self.inProcess = false
            self.targetMate!.inProcess = false
            self.targetMate?.targetMate = nil
            self.targetMate?.checkPriority()
            self.targetMate = nil
            self.checkPriority()
        }
    }
    
    func birth() {
        if self.sex == .Female {
            for _ in 0...11 {
                if Int.random(in: 0...1) == 0 {
                    _ = Rabbit(Position: self.node.worldPosition, Handler: self.handler)
                }
            }
        }
    }
    
}
