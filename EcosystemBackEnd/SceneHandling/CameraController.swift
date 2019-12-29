//
//  CameraController.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 12/28/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Camera {
    var node: SCNNode
    var camera: SCNCamera {
        didSet {
            self.node.camera = self.camera
        }
    }
    var targetPoint: SCNVector3
    var cameraType: CameraType
    var root: SCNNode
    
    init(Position: SCNVector3, Target: SCNVector3, SceneRootNode: SCNNode) {
         self.node = SCNNode()
            self.camera = SCNCamera()
            self.camera.zNear = 0
            self.node.camera = self.camera
            self.node.geometry = SCNSphere(radius: 0.2)
            self.node.look(at: SCNVector3().zero())
            self.root = SceneRootNode
            self.root.addChildNode(self.node)
            self.node.position = Position
            self.targetPoint = Target
            self.cameraType = .targeted
    }
    
    init(Position: SCNVector3, SceneRootNode: SCNNode) {
         self.node = SCNNode()
         self.camera = SCNCamera()
         self.node.camera = self.camera
         self.node.geometry = SCNCone(topRadius: 0.1, bottomRadius: 0.4, height: 3)
         self.root = SceneRootNode
         self.root.addChildNode(self.node)
         self.node.position = Position
         self.targetPoint = SCNVector3().zero()
         self.cameraType = .positionDependent
    }
    
    func look() {
        if self.cameraType == .targeted {
            self.node.look(at: targetPoint)
        }
    }
    
}

enum CameraType {
    case targeted
    case positionDependent
    case following
}
