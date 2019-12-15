//
//  GameController.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/27/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa
import SceneKit

class GameController: NSViewController {
    
    convenience init () {
        self.init(nibName: "GameController", bundle: nil)
    }
    
    var GameView = SCNView()
    var handler: EnvironmentHandler!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        handler = EnvironmentHandler("art.scnassets/GameScene.scn")
        handler.View = GameView
       let scene = handler.Scene
       
       // set the scene to the view
       GameView.scene = scene
       
       GameView.loops = true
       GameView.isPlaying = true
       // allows the user to manipulate the camera
       GameView.allowsCameraControl = true
        GameView.scene?.isPaused = false
        
       // show statistics such as fps and timing information
//        if building == true {
       GameView.showsStatistics = true
//        }
       GameView.delegate = self
        
        GameView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(GameView)
        GameView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        GameView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        GameView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        GameView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        Manager!.gameDidLoad()
        
    }
    
}
