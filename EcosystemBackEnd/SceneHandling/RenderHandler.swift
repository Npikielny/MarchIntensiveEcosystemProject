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
        if let _ = camera {
            if cameraRotation.x < 0 {
               camera.rotationX += CGFloat.pi/60
           }else if self.cameraRotation.x > 0 {
               camera.rotationX -= CGFloat.pi/60
           }

           if self.cameraRotation.y > 0 {
               camera.rotationY += CGFloat.pi/60
           }else if self.cameraRotation.y < 0 {
               camera.rotationY -= CGFloat.pi/60
           }
            
            camera.node.eulerAngles = SCNVector3(camera.rotationY, camera.rotationX, camera.node.eulerAngles.z)
            
            if cameraMovement.x > 0 {
                camera.node.position = camera.node.position + SCNVector3(CGFloat(1)/CGFloat(5),0,0)
            }else if cameraMovement.x < 0 {
                camera.node.position = camera.node.position + SCNVector3(CGFloat(-1)/CGFloat(5),0,0)
            }
            if cameraMovement.y > 0 {
                camera.node.position = camera.node.position + SCNVector3(0,CGFloat(1)/CGFloat(5),0)
            }else if cameraMovement.y < 0 {
                camera.node.position = camera.node.position + SCNVector3(0,CGFloat(-1)/CGFloat(5),0)
            }
            if cameraMovement.z > 0 {
                camera.node.position = camera.node.position + SCNVector3(0,0,CGFloat(1)/CGFloat(5))
            }else if cameraMovement.z < 0 {
                camera.node.position = camera.node.position + SCNVector3(0,0,CGFloat(-1)/CGFloat(5))
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if self.handler.initialized {
            self.handler.process()
            self.handler.updateTime()
        }
        
        
        
        
        
    }
    
}
