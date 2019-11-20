//
//  VectorHelpers.swift
//  EcosystemBackEnd
//
//  Created by Christopher Lee on 11/11/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit
import GameplayKit

extension SCNVector3 {
    func getMagnitude() -> CGFloat {
        return pow(pow(self.x,2)+pow(self.y,2)+pow(self.z,2), 0.5)
        
    }
    
    func scalarMultiplication(Scalar: CGFloat) -> SCNVector3 {
        let Vector = self
        return SCNVector3(x: Vector.x*Scalar, y: Vector.y*Scalar, z: Vector.z*Scalar)
    }
    
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    static func += (left: inout SCNVector3, right: SCNVector3) {
        left = SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func -= (left: inout SCNVector3, right: SCNVector3) {
        left = SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func * (left: inout SCNVector3, right: CGFloat) {
        left = SCNVector3(left.x * right, left.y * right, left.z * right)
    }
    
    static func == (left: SCNVector3, right: SCNVector3) -> Bool {
        if (left.x==right.x&&left.y==right.y&&left.z==left.z) {return true}else{return false}
    }
    
    static func != (left: SCNVector3, right: SCNVector3) -> Bool {
        return !(left == right)
    }
    
    func translatedDirectionVector(Center: SCNVector3) -> SCNVector3 {
        return directionVector(Center: Center) + Center
    }
    
    func directionVector(Center: SCNVector3) -> SCNVector3 {
        return (self - Center).unitVector()
    }
    
    func unitVector() -> SCNVector3 {
        let magnitude = pow(pow(self.x, 2)+pow(self.y, 2)+pow(self.z, 2), 0.5)
        if magnitude > 0 {
            return self.scalarMultiplication(Scalar: 1/magnitude)
        }else {
            return SCNVector3().zero()
        }
    }
    
    func toMagnitude(_ Magnitude: CGFloat) -> SCNVector3 {
        return self.unitVector().scalarMultiplication(Scalar: Magnitude)
    }
    
    func zero() -> SCNVector3 {
        return SCNVector3(x: 0, y: 0, z: 0)
    }
    
    func clamp(Min: CGFloat, Max: CGFloat) -> SCNVector3 {
        if self.getMagnitude() < Min {
            return self.toMagnitude(Min)
        }else if self.getMagnitude() > Max {
            return self.toMagnitude(Max)
        }else {
            return self
        }
    }
    
    func clampMagnitudeComponent(ComponentMinMax: [component:(CGFloat,CGFloat)]) {
        var finalVector = self
        let clampComponent: (CGFloat, CGFloat, CGFloat) -> CGFloat = {if abs($0) > $1 && abs($0) < $2 {return $0}else if abs($0) < $1 {return $1}else {return $2}}
        
        for i in ComponentMinMax {
            if i.key == .y {
                finalVector = finalVector.setValue(Component: .y, Value: clampComponent(finalVector.y,i.value.0,i.value.1))
            }else if i.key == .x {
                finalVector = finalVector.setValue(Component: .x, Value: clampComponent(finalVector.x,i.value.0,i.value.1))
            }else if i.key == .z {
                finalVector = finalVector.setValue(Component: .z, Value: clampComponent(finalVector.z,i.value.0,i.value.1))
            }
        }
    }
    
    func clampComponent(ComponentMinMax: [component:(CGFloat,CGFloat)]) -> SCNVector3 {
        var finalVector = self
        let clampComponent: (CGFloat, CGFloat, CGFloat) -> CGFloat = {if ($0) > $1 && ($0) < $2 {return $0}else if ($0) < $1 {return $1}else {return $2}}
        
        for i in ComponentMinMax {
            if i.key == .y {
                finalVector = finalVector.setValue(Component: .y, Value: clampComponent(finalVector.y,i.value.0,i.value.1))
            }else if i.key == .x {
                finalVector = finalVector.setValue(Component: .x, Value: clampComponent(finalVector.x,i.value.0,i.value.1))
            }else if i.key == .z {
                finalVector = finalVector.setValue(Component: .z, Value: clampComponent(finalVector.z,i.value.0,i.value.1))
            }
        }
        return finalVector
    }
    
    func setValue(Component: component, Value: CGFloat) -> SCNVector3 {
        if Component == .x {
            return SCNVector3(Value,self.y,self.z)
        }else if Component == .y {
            return SCNVector3(self.x,Value,self.z)
//        }else if Component == .z {
//            return SCNVector3(self.x,self.y,Value)
        }
        else {
                return SCNVector3(self.x,self.y,Value)
            }
    }
    
    func random() -> SCNVector3 {
        let vector = SCNVector3(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5), z: CGFloat.random(in: -5...5)).unitVector()
        if vector.getMagnitude() == 0 {
            return random()
        }else {
            return vector
        }
    }
    
    func zero(_ Component: component...) -> SCNVector3 {
        var vector = self
        for i in Component {
            if i == .x {
                vector = SCNVector3(x: 0, y: vector.y, z: vector.z)
            }else if i == .y {
                vector = SCNVector3(x: vector.x, y: 0, z: vector.z)
            }else if i == .z {
                vector = SCNVector3(x: vector.x, y: vector.y, z: 0)
            }
        }
        return vector
    }
    
    func initOfComponent(Component: component, Value: CGFloat) -> SCNVector3 {
        if Component == .x {
            return SCNVector3(Value,0,0)
        }else if Component == .y {
            return SCNVector3(0,Value,0)
        }else if Component == .z {
            return SCNVector3(0,0,Value)
        }else {
            fatalError("Component Not Implemented")
        }
    }
    
}

enum component {
    case x
    case y
    case z
}
