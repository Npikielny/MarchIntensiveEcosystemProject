//
//  PrefabHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/13/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

func getPrefab(_ FileName: String, Shaders: String?) -> SCNNode {
    let createSprite: SCNNode = {
        let virtualObjectScene: SCNScene = SCNScene(named: "art.scnassets/"+FileName)!
        
        let wrapperNode = SCNNode()
        
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            child.movabilityHint = .movable
            child.castsShadow = true
            if let shader = Shaders {
                if let _ = child.geometry {
                    for mat in child.geometry!.materials {
                        mat.shaderModifiers = [.geometry:getShader(from: shader)]
                    }
                }else {
                    
                }
            }
            wrapperNode.addChildNode(child)
        }
        wrapperNode.castsShadow = true
        return wrapperNode
    }()
    return createSprite
}
