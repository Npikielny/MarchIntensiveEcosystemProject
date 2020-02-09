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
    
    var cameraMovement: SIMD3<Float> = SIMD3(0,0,0)
    var cameraRotation: SIMD2<Float> = SIMD2(0,0)
    var camera: Camera!
    
    
    convenience init () {
        self.init(nibName: "GameController", bundle: nil)
    }
    
    var GameView = SCNView()
    var handler: EnvironmentHandler!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        handler = EnvironmentHandler("art.scnassets/GameScene.scn", InitialNumberOfBunnies: 2, Controller: self)
        handler.View = GameView
		let scene = handler.Scene
        
		// set the scene to the view
		GameView.scene = scene
		GameView.loops = true
		GameView.isPlaying = true
		// allows the user to manipulate the camera
		GameView.allowsCameraControl = true
        GameView.scene?.isPaused = false
		GameView.defaultCameraController.interactionMode = .fly
		GameView.defaultCameraController.inertiaEnabled = true
        
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
//        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
//        var gestureRecognizers = GameView.gestureRecognizers
//        gestureRecognizers.insert(clickGesture, at: 0)
//        GameView.gestureRecognizers = gestureRecognizers
        
        
    }
    
//    override func keyDown(with event: NSEvent) {
//        if let _ = self.camera {
//            if event.keyCode == 13 {cameraMovement.z = -1} //W
//            if event.keyCode == 0 {cameraMovement.x = -1} //A
//            if event.keyCode == 1 {cameraMovement.z = 1} //S
//            if event.keyCode == 2 {cameraMovement.x = 1} //D
//            if event.keyCode == 126 {cameraRotation.y = 1} //Forward
//            if event.keyCode == 123 {cameraRotation.x = -1} //Left
//            if event.keyCode == 125 {cameraRotation.y = -1} //Backward
//            if event.keyCode == 124 {cameraRotation.x = 1} //Right
//            if event.keyCode == 44 {camera.rotationY = 0}
//            if event.keyCode == 12 {cameraMovement.y = -1} //Down
//            if event.keyCode == 14 {cameraMovement.y = 1} //Up
//        }
//    }
//
//    override func keyUp(with event: NSEvent) {
//        if let _ = self.camera {
//            if let _ = self.camera {
//                if event.keyCode == 13 {cameraMovement.z = 0} //W
//                if event.keyCode == 0 {cameraMovement.x = 0} //A
//                if event.keyCode == 1 {cameraMovement.z = 0} //S
//                if event.keyCode == 2 {cameraMovement.x = 0} //D
//                if event.keyCode == 126 {cameraRotation.y = 0} //Up
//                if event.keyCode == 123 {cameraRotation.x = 0} //Left
//                if event.keyCode == 125 {cameraRotation.y = 0} //Down
//                if event.keyCode == 124 {cameraRotation.x = 0} //Right
//                if event.keyCode == 12 {cameraMovement.y = 0} //Down
//                if event.keyCode == 14 {cameraMovement.y = 0} //Up
//            }
//        }
//    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
		handler.skyIndex += 1
        handler.setSky(Index: handler.skyIndex)
        self.handler.time += Float.pi/90000 * 2500
        self.handler.updateTime()
    }
    
}
