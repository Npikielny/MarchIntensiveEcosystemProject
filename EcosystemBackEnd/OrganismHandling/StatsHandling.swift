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
    
}
