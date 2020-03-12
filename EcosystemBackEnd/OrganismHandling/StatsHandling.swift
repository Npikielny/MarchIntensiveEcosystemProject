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
        if self.age < 6 {
            let value = (self.age+6)/12
            self.node.scale = SCNVector3(value,value,value)
        }
        self.health -= 100/288/60/1.4
        self.Speed = CGFloat(Float(self.maxSpeed)/(1 + pow(2.18,0.1*(self.age-15))))
        let ageMultiplier: Float = 1 + pow(2.18,-0.3*(self.age-6))
        if self.inProcess == false {
            if self.hunger > 0 {
                self.hunger = Float(CGFloat(self.hunger)-self.efficiency*((self.velocity.getMagnitude()) * CGFloat(ageMultiplier) * 0.0018 / 2))
                self.hunger -= 0.0001
                
            }else {
                self.hunger = 0
                self.health -= ageMultiplier * 0.025 * self.age/6
           }
            if self.thirst > 0 {
                if (self.priority == .Water) == false {
                    self.thirst = Float(CGFloat(self.thirst)-self.efficiency*((self.velocity.getMagnitude()) * CGFloat(ageMultiplier) * 0.0027 / 2))
                    self.thirst -= 0.0001
               }
                
            }else {
                self.thirst = 0
                self.health -= ageMultiplier * 0.025 * self.age/6
            }
            if self.breedingUrge > 0 {
                if (self.age >= 6) && (self.age <= 18) {
                    if (self.hunger > 40) && (self.thirst > 40) {
                        self.breedingUrge -= Float.random(in: 0.005...0.05)
                    }
                }else {
                    self.breedingUrge = self.maxbreedingUrge
               }   
            }else {
                self.breedingUrge = 0
            }
        }
    }
    
    func drink() -> Bool {
        if self.thirst >= self.maxthirst {
            self.thirst = self.maxthirst
            return true
        }else {
            self.thirst += 0.1
            return false
        }
    }
    
    func eat(Item: inout Food) -> Bool {
        if Item.foodValue <= 0 {
            Item.eaten()
            return true
        }else if self.hunger >= self.maxhunger {
            return true
        }else {
            self.hunger += 0.1
            Item.foodValue -= 0.1
            return false
        }
    }
    
    func breed() -> Bool{
        self.breedingUrge += 0.1
//        if self.velocity.y == 0 && bottom(self) - 2 < 0.8 {
//            self.velocity = SCNVector3(0,2,0)
//        }
        
        if self.breedingUrge >= self.maxbreedingUrge {
            self.breedingUrge = self.maxbreedingUrge
            self.targetMate?.breedingUrge = self.targetMate!.maxbreedingUrge
            if self.targetMate!.sex == .Female {
                self.targetMate!.birth()
            }else {
                birth()
                return true
            }
            self.inProcess = false
            self.targetMate!.inProcess = false
            self.targetMate?.targetMate = nil
            self.targetMate?.checkPriority()
            self.targetMate = nil
            self.checkPriority()
        }
        return false
    }
    
    func reproduce() {
        let baby = animalReproductionIndex[self.speciesData.name]!(self.node.worldPosition, self.handler)
        self.shuffle(Child: baby, Parent1: self, Parent2: self.targetMate!)
    }
    
    func shuffle(Child: Animal, Parent1: Animal, Parent2: Animal) {
        let rand = {return [Parent1, Parent2].randomElement()}
        
        Child.maxhunger = rand()!.maxhunger
        Child.maxthirst = rand()!.maxthirst
        Child.maxhealth = rand()!.maxhealth
        Child.maxbreedingUrge = rand()!.maxbreedingUrge
        Child.maxSpeed = rand()!.maxSpeed
        Child.efficiency = rand()!.efficiency
        
        Child.hunger = Child.maxhunger
        Child.thirst = Child.maxthirst
        Child.health = Child.maxhealth
        
        
    }
    
    func birth() {
        if self.sex == .Female {
            for _ in 0...11 {
                if Int.random(in: 0...1) == 0 {
                    self.reproduce()
                }
            }
        }
    }
    
}
