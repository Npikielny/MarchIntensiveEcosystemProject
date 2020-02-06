//
//  SceneHandling.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/14/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class EnvironmentScene: SCNScene {
    
}


extension GameController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        if self.handler.initialized {
            self.handler.Physics()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if self.handler.initialized {
            self.handler.process()
//            self.handler.updateTime()
        }
    }
    
}
