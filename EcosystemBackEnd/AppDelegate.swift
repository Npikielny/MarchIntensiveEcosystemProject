//
//  AppDelegate.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/10/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//
//test
import Cocoa

var Manager: WindowManager!
var building: Bool = false
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Insert code here to initialize your application
        let controller = FrontHolder()
        let window = NSWindow(contentViewController: controller)
        controller.window = window
        window.makeKeyAndOrderFront(self)
    }
        
}

struct Fonts {
    static let sourceSansPro = "SourceSansPro-Regular"
    static let sourceSansProSemiBold = "SourceSansPro-SemiBold"
    static let sourceSansProBold = "SourceSansPro-Bold"
    static let sourceSansProLight = "SourceSansPro-Light"
    static let sourceSansProExtraLight = "SourceSansPro-ExtraLight"
}

