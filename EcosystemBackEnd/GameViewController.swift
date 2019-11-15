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


