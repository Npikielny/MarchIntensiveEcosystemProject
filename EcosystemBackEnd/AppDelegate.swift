//
//  AppDelegate.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/10/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa

var MainScene: EnvironmentHandler!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let debugWindow = NSWindow(contentViewController: DebugWindow())
        debugWindow.makeKeyAndOrderFront(self)
    }
    
}
