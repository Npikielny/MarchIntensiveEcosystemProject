//
//  LookHandling.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/20/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

extension Animal {
    
    func look() {
        if self.target != self.node.worldPosition {
            if self.lookType == .Velocity {
                if self.velocity.getMagnitude() > 0 {
                    let dotProduct = self.velocity.x*self.velocity.x+self.velocity.z*self.velocity.z
                    let holder = dotProduct/((self.velocity.getMagnitude())*((self.velocity.zero(.y)).getMagnitude()))
                    if self.velocity.y < 0 {
        //                self.node.eulerAngles = self.getLookingAngle(self.target) + SCNVector3(acos(holder)-CGFloat.pi/4,0,0)
                        self.node.eulerAngles = self.getLookingAngle(self.target) + SCNVector3(acos(holder)+4*CGFloat.pi/2,0,0)
                    }else {
                        self.node.eulerAngles = self.getLookingAngle(self.target) + SCNVector3(-acos(holder),0,0)
        //                self.node.eulerAngles = self.getLookingAngle(self.target) + SCNVector3(0,0,0)
                    }
                }
            }else {
                self.node.eulerAngles = self.getLookingAngle(self.velocity + self.node.worldPosition)
            }
        }
    }
    
    func getAngleFromDirectionVector(_ DirectionVector: SCNVector3) -> SCNVector3 {
        if DirectionVector.x != 0 {
            let ata = atan(DirectionVector.z/DirectionVector.x)
            if DirectionVector.x < 0 {
                return SCNVector3(0,ata+CGFloat.pi,0)
            }else {
                return SCNVector3(0,ata,0)
            }
        }else {
            return SCNVector3().zero()
        }
    }
    
    func getLookingAngle(_ Target: SCNVector3) -> SCNVector3 {
        let DirectionVector = Target.directionVector(Center: self.node.worldPosition)
        return getAngleFromDirectionVector(DirectionVector).scalarMultiplication(Scalar: -1)+SCNVector3(x: 0, y: CGFloat.pi*1/2, z: 0)
    }
    
}


enum LookType {
    case Velocity
    case Forward
}
