//
//  FrontHolder.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 12/19/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa

class FrontHolder: NSViewController {

    var window: NSWindow?
    
    var classicButton: NSButton = {
        let button = NSButton(title: "3D Simulation", target: self, action: #selector(classic))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.addSubview(classicButton)
        
        classicButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        classicButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func classic() {
        let splashCont = SplashController()
            let splashScreen = NSWindow(contentViewController: splashCont)
            splashScreen.makeKeyAndOrderFront(self)
            Manager = WindowManager(SplashScreen: splashScreen, splashController: splashCont)
            let _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(startGame), userInfo: nil, repeats: false)
        self.window?.close()
    }   
        
    @objc func startGame() {
        Manager.loadGame()
    }
    
}
