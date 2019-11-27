//
//  AppDelegate.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/10/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa

var Manager: WindowManager!
var building: Bool = false
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        let debugWindow = NSWindow(contentViewController: DebugWindow())
        
//        debugWindow.makeKeyAndOrderFront(self)
        let splashScreen = NSWindow(contentViewController: SplashController())
        splashScreen.makeKeyAndOrderFront(self)
        Manager = WindowManager(SplashScreen: splashScreen)
        let _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(startGame), userInfo: nil, repeats: false)
    }
    
    @objc func startGame() {
        Manager.loadGame()
    }
    
}
