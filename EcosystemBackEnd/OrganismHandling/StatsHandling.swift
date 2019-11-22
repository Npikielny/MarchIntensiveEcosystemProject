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
            self.hunger = Float(CGFloat(self.hunger)-((self.node.physicsBody?.velocity.getMagnitude())! * 0.001))
        }else {
            self.hunger = 0
            self.health -= 0.5
        }
        if self.thirst > 0 {
            self.thirst = Float(CGFloat(self.thirst)-((self.node.physicsBody?.velocity.getMagnitude())! * 0.0015))
        }else {
            self.thirst = 0
            self.health -= 1
        }
    }
    
}
