//
//  WindowManager.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/27/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa

class WindowManager {
    
    var GameWindow: NSWindow!
    var gameController: GameController?
    var splashScreen: NSWindow
    var splashController: SplashController
    init(SplashScreen: NSWindow, splashController: SplashController) {
        self.splashScreen = SplashScreen
        self.splashController = splashController
        
        Manager = self
        
    }
    
    func loadGame() {
//        let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(increment), userInfo: nil, repeats: true)
        self.gameController = GameController()
        self.GameWindow = NSWindow(contentViewController: gameController!)
//        self.GameWindow.makeKeyAndOrderFront(self)
        self.GameWindow.title = "Life"
//        gameDidLoad()
        setupGame()
    }
    
    @objc func setupGame() {
        if self.gameController!.handler.setupFunctionIndex < self.gameController!.handler.setupFunctions.count {
            self.gameController!.handler.runSetupFunction()
            increment()
            let _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setupGame), userInfo: nil, repeats: false)
        }else {
            showGame()
        }
        
    }
    
    func showGame() {
        GameWindow.makeKeyAndOrderFront(self)
        gameDidLoad()
    }
    
    func gameDidLoad() {
        splashScreen.close()
    }
    
    func increment() {
        splashController.progressBar.increment(by: Double(self.gameController!.handler.setupFunctionIndex)/Double(self.gameController!.handler.setupFunctions.count))
    }
}
