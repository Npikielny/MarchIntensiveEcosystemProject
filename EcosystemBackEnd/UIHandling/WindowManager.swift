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
    var UserInputWindow: (NSWindow,UserControls)
    init(SplashScreen: NSWindow, splashController: SplashController) {
        
        let userController = UserControls()
        let userInputWindow = NSWindow(contentViewController: userController)
        self.UserInputWindow = (userInputWindow,userController)
        
        self.splashScreen = SplashScreen
        self.splashController = splashController
        SplashScreen.title = ""
        Manager = self
        self.UserInputWindow.1.Manager = self
    }
    
    func loadGame() {
        self.gameController = GameController()
        self.GameWindow = NSWindow(contentViewController: gameController!)
        self.GameWindow.title = "Life"
        setupGame()
    }
    
    @objc func setupGame() {
        if self.gameController!.handler.setupFunctionIndex < self.gameController!.handler.setupFunctions.count {
            self.gameController!.handler.runSetupFunction()
            increment()
            let _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(setupGame), userInfo: nil, repeats: false)
        }else {
            showGame()
        }
        
    }
    
    func showGame() {
        GameWindow.makeKeyAndOrderFront(self)
        gameDidLoad()
        let size = NSScreen.main?.frame.size
        GameWindow.setFrame(NSRect(x: 0, y: size!.height*0.05, width: size!.width*0.8, height: size!.height*0.95), display: true)
        
        UserInputWindow.0.makeKeyAndOrderFront(self)
        UserInputWindow.0.setFrame(NSRect(x: size!.width*0.8, y: size!.height*0.05, width: size!.width*0.2, height: size!.height*0.95), display: true)
    }
    
    func gameDidLoad() {
        splashScreen.close()
    }
    
    func increment() {
        splashController.progressBar.increment(by: Double(self.gameController!.handler.setupFunctionIndex)/Double(self.gameController!.handler.setupFunctions.count))
        if self.gameController!.handler.setupFunctionIndex < self.gameController!.handler.setupFunctions.count - 1 {
            splashController.progressText.string = (self.gameController?.handler.setupFunctions[(self.gameController?.handler.setupFunctionIndex)!+1].1)!
        }else {
            splashController.progressText.string = "Loading Game"
        }
        
    }
}
