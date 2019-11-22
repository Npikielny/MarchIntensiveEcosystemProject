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
        if self.lookType == .Velocity {
            self.node.look(at: self.node.worldPosition + self.node.physicsBody!.velocity)
        }else {
            self.node.eulerAngles = self.getLookingAngle(self.target)
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
