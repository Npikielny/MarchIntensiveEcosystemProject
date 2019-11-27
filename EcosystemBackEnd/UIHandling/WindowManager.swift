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
    init(SplashScreen: NSWindow) {
        self.splashScreen = SplashScreen
        Manager = self
    }
    
    func loadGame() {
        self.gameController = GameController()
        self.GameWindow = NSWindow(contentViewController: gameController!)
        self.GameWindow.makeKeyAndOrderFront(self)
        self.GameWindow.title = "Life"
        gameDidLoad()
    }
    
    func gameDidLoad() {
        splashScreen.close()
    }
}
