//
//  TreeHandling.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/12/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import GameplayKit
import SceneKit

class TreeGenerator {
    var pines = [Acacia]()
    var fails: Int = 0
    init(NumberOfPines: Int, NoiseMap: GKNoiseMap, Width: CGFloat, Height: CGFloat, widthCount: Int, heightCount: Int) {
        let getDistance: ((Int, Int), SCNVector3) -> CGFloat = {
            let xDistance = $1.x - CGFloat($0.0)/CGFloat(widthCount)*Width
            let yDistance = $1.y - CGFloat($0.1)/CGFloat(heightCount)*Height
            return pow(pow(xDistance,0.5)+pow(yDistance,0.5), 2)
        }
        var iterant: Int = 0
        while (pines.count < NumberOfPines) && (fails <= 100) {
//            print(iterant)
            iterant += 1
            let attempt = (Int.random(in: 0..<widthCount),Int.random(in: 0..<heightCount))
            if NoiseMap.interpolatedValue(at: vector_float2(Float(attempt.0),Float(attempt.1))) <= -1 && pines.map({getDistance(attempt,$0.position)}).contains(where: {$0<=2}) == false{
                    pines.append(Acacia(Position: SCNVector3(x: CGFloat(attempt.0)/CGFloat(widthCount)*Width, y: 0, z: CGFloat(attempt.1)/CGFloat(heightCount)*Height)))
            }else {
                fails += 1
            }
            
        }
        for pine in pines {
            pine.node.worldPosition = pine.position - SCNVector3(Width/2,-2,Height/2)
        }
    }
    
}

class Acacia {
    
    var position: SCNVector3
    var node: SCNNode
    init(Position: SCNVector3) {
        self.position = Position
        let createSprite: SCNNode = {
            let virtualObjectScene: SCNScene = {
//                if Int.random(in: 0...1) == 0 {
                    return SCNScene(named: "art.scnassets/polyTree.scn")!
//                }else {
//                    return SCNScene(named: "art.scnassets/pine.scn")!
//                }
                
            }()
            
            let wrapperNode = SCNNode()
            
            for child in virtualObjectScene.rootNode.childNodes {
                child.geometry?.firstMaterial?.lightingModel = .physicallyBased
                child.movabilityHint = .movable
                if let _ = child.geometry {
                    for mat in child.geometry!.materials {
                        mat.shaderModifiers = [.geometry:getShader(from: "tree")]
                    }
                }
                wrapperNode.addChildNode(child)
                }
                
                return wrapperNode
        }()
        self.node = createSprite
        self.node.eulerAngles = SCNVector3(CGFloat.random(in: -0.2...0.2), CGFloat.random(in: 0...CGFloat.pi*2), CGFloat.random(in: -0.2...0.2))
    }
    
}

class Pine {
    
    var position: SCNVector3
    var node: SCNNode
    init(Position: SCNVector3) {
        self.position = Position
        let createSprite: SCNNode = {
            let virtualObjectScene: SCNScene = {
//                if Int.random(in: 0...1) == 0 {
                    return SCNScene(named: "art.scnassets/pine.scn")!
//                }else {
//                    return SCNScene(named: "art.scnassets/pine.scn")!
//                }
                
            }()
            
            let wrapperNode = SCNNode()
            
            for child in virtualObjectScene.rootNode.childNodes {
                child.geometry?.firstMaterial?.lightingModel = .physicallyBased
                child.movabilityHint = .movable
//                if let _ = child.geometry {
//                    for mat in child.geometry!.materials {
//                        mat.shaderModifiers = [.geometry:getShader(from: "tree")]
//                    }
//                }
                wrapperNode.addChildNode(child)
                }
                
                return wrapperNode
        }()
        self.node = createSprite
        self.node.eulerAngles = SCNVector3(CGFloat.random(in: -0.2...0.2), CGFloat.random(in: 0...CGFloat.pi*2), CGFloat.random(in: -0.2...0.2))
    }
    
}
