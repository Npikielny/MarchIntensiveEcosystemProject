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
	
	var splitController: NSSplitViewController?
    var gameController: GameController?
	var userControls: UserControls?
    var splashScreen: NSWindow
    var splashController: SplashController
//	var gameView: NSSplitViewItem?
//	var userView: NSSplitViewItem?
	
    init(SplashScreen: NSWindow, splashController: SplashController) {
        
        self.splashScreen = SplashScreen
        self.splashController = splashController
        SplashScreen.title = ""
        
    }
    
    func loadGame() {
		self.splitController = NSSplitViewController()
		splitController?.splitView.dividerStyle = .thick
		
        self.gameController = GameController()
		self.userControls = UserControls()
		self.userControls?.Manager = self
        
		let gameView = NSSplitViewItem(contentListWithViewController: gameController!)
		let userView = NSSplitViewItem(sidebarWithViewController: userControls!)
		
		[gameView, userView].forEach { splitController?.addSplitViewItem($0) }
		
        self.GameWindow = NSWindow(contentViewController: splitController!)
        self.GameWindow.title = "Life"
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
        let size = NSScreen.main?.frame.size
        GameWindow.setFrame(NSRect(x: 0, y: Int(size!.height), width: Int(size!.width), height: Int(size!.height)), display: true)
        
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
