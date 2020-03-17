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
		GameView.allowsCameraControl = false
        GameView.scene?.isPaused = false
//		GameView.defaultCameraController.interactionMode = .fly
//		GameView.defaultCameraController.inertiaEnabled = true
        
		// show statistics such as fps and timing information
//        if building == true {
            GameView.showsStatistics = false
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
    
    var vertical = keybinding()
    var horizontal = keybinding()
    var forward = keybinding()
    
    var verticalRotate = keybinding()
    var horizontalRotate = keybinding()
    
    var speed = keybinding()
    
    
    override func keyDown(with event: NSEvent) {
//        if let _ = self.camera {
        if event.keyCode == 13 {forward.positive = true} //W
        if event.keyCode == 1 {forward.negative = true} //S
        if event.keyCode == 0 {horizontal.negative = true} //A
        if event.keyCode == 2 {horizontal.positive = true} //D
        if event.keyCode == 126 {} //Forward
        if event.keyCode == 125 {} //Backward
        if event.keyCode == 123 {} //Left
        if event.keyCode == 124 {} //Right
        if event.keyCode == 12 {vertical.negative = true} //Down
        if event.keyCode == 14 {vertical.positive = true} //Up
        if event.keyCode == 8 {speed.positive = true} //Speed
//        }
    }
//
    override func keyUp(with event: NSEvent) {
        if event.keyCode == 13 {forward.positive = false} //W
        if event.keyCode == 1 {forward.negative = false} //S
        if event.keyCode == 0 {horizontal.negative = false} //A
        if event.keyCode == 2 {horizontal.positive = false} //D
        if event.keyCode == 126 {} //Forward
        if event.keyCode == 125 {} //Backward
        if event.keyCode == 123 {} //Left
        if event.keyCode == 124 {} //Right
        if event.keyCode == 12 {vertical.negative = false} //Down
        if event.keyCode == 14 {vertical.positive = false} //Up
        if event.keyCode == 8 {speed.positive = false} //Speed
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
		handler.skyIndex += 1
        handler.setSky(Index: handler.skyIndex)
        self.handler.time += Float.pi/90000 * 2500
        self.handler.updateTime()
    }
    
}

class keybinding {
    var positive: Bool = false
    var negative: Bool = false
    lazy var net: () -> CGFloat = {
        if (self.positive && self.negative) || (self.positive == false && self.negative == false) {
            return CGFloat(0)
        }else if self.positive {
            return CGFloat(1)
        }else {
            return CGFloat(-1)
        }
    }
    init() {}
}
