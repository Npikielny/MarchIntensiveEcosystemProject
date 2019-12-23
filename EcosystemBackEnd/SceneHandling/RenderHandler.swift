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
        self.handler.process()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        self.handler.Physics()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        self.handler.updateTime()
    }
    
}
