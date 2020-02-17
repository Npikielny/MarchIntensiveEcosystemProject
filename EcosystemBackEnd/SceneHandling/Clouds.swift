//
//  Clouds.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 2/16/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import SceneKit
class Cloud {
    
    var travelRadius: CGFloat
    
    var node: SCNNode
    
    init(RadiusRange: ClosedRange<CGFloat>, Spread: ClosedRange<CGFloat>, VerticalCompressionFactor: CGFloat, CloudCount: Int) {
        
        node = SCNNode()
        travelRadius = CGFloat.random(in: RadiusRange)
        self.node.worldPosition = SCNVector3().random().setValue(Component: .y, Value: 0).toMagnitude(travelRadius)
        
        let mainAngle: CGFloat = {
            let final = node.position
            if final.x < 0 {
                return atan(node.worldPosition.z/node.worldPosition.x) + CGFloat.pi
            }else {
                return atan(node.worldPosition.z/node.worldPosition.x)
            }
        }()
        
        var cloudList = [SCNNode]()
        var maxAngle: CGFloat?
        var minAngle: CGFloat?
        
        for _ in 0...CloudCount {
            let x = getPrefab("ico.scn", Shaders: "cloudShader")
            x.position += SCNVector3().random().toMagnitude(CGFloat.random(in: Spread))
            x.position = x.position.setValue(Component: .y, Value: x.position.y * VerticalCompressionFactor)
            
            x.childNodes.first?.geometry?.materials.first?.setValue(Float((x.position+node.worldPosition).getMagnitude()), forKey: "travelRadius")
            
            let angle: CGFloat = {
                let final = x.position + node.position
                if final.x < 0 {
                    return atan(final.z/final.x) + CGFloat.pi
                }else {
                    return atan(final.z/final.x)
                }
            }()
            if let _ = maxAngle {
                if angle - mainAngle > maxAngle! {
                    maxAngle = angle - mainAngle
                }
            }else {
                maxAngle = angle - mainAngle
            }
            
            if let _ = minAngle {
                if angle - mainAngle < minAngle! {
                    minAngle = angle - mainAngle
                }
            }else {
                minAngle = angle - mainAngle
            }
            
            print(angle - mainAngle)
            
            x.childNodes.first?.geometry?.materials.first?.setValue(angle, forKey: "angle")
            x.childNodes.first?.geometry?.materials.first?.setValue(mainAngle - angle, forKey: "offset")
            
            cloudList.append(x)
            
            node.addChildNode(x)
        }
        
        for i in cloudList {
            i.childNodes.first?.geometry?.materials.first?.setValue(Float(maxAngle! - minAngle!), forKey: "moveRate")
        }
        
        
    }
    
}
