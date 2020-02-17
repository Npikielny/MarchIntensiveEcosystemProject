//
//  CameraController.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 12/28/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Camera {
    let node: SCNNode
    let camera: SCNCamera
    var targetPoint: SCNVector3
    var cameraType: CameraType
    var root: SCNNode
    var rotationY: CGFloat = 0
    var rotationX: CGFloat = 0
    
    init(Position: SCNVector3, Target: SCNVector3, SceneRootNode: SCNNode) {
        self.node = SCNNode()
        self.camera = SCNCamera()
        self.camera.zNear = 0
		self.camera.zFar = 1200
        self.node.camera = self.camera
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
        self.root = SceneRootNode
        self.root.addChildNode(self.node)
        self.node.position = Position
        self.targetPoint = SCNVector3().zero()
        self.cameraType = .positionDependent
    }
    
    func getLookingAngle(_ Target: SCNVector3) -> SCNVector3 {
        let DirectionVector = Target.directionVector(Center: self.node.worldPosition)
        return getAngleFromDirectionVector(DirectionVector).scalarMultiplication(Scalar: -1)+SCNVector3(x: 0, y: CGFloat.pi*1/2, z: 0)
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
    
}

enum CameraType {
    case targeted
    case positionDependent
    case following
}

