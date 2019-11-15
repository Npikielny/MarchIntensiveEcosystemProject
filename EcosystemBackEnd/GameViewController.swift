//
//  GameViewController.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/10/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    var handler: EnvironmentHandler!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        handler = EnvironmentHandler("art.scnassets/GameScene.scn")
        let scene = handler.Scene
        
        // create and add a camera to the scene
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        cameraNode.camera?.zFar = 1000
//        scene.rootNode.addChildNode(cameraNode)
//        
//        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
//        
        // create and add a light to the scene
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .omni
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//        scene.rootNode.addChildNode(lightNode)
//        
//        // create and add an ambient light to the scene
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        scnView.loops = true
        scnView.isPlaying = true
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        scnView.delegate = self
        
    }
    
}


