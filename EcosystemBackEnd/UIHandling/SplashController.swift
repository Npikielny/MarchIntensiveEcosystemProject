//
//  SplashScreen.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/27/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa

class SplashController: NSViewController {

    convenience init() {
        self.init(nibName: "SplashScreen", bundle: nil)
    }
    var progressBar: NSProgressIndicator = {
        let bar = NSProgressIndicator()
        bar.minValue = 0
        bar.maxValue = 1
        bar.doubleValue = 0.0
        bar.isBezeled = true
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let screen = NSScreen.main?.frame.size
        view.setFrameSize(screen!)
        let bg = NSImageView(image: NSImage(named: "SplashScreen")!)
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.imageScaling = .scaleProportionallyUpOrDown
        view.addSubview(bg)
        view.widthAnchor.constraint(lessThanOrEqualToConstant: screen!.width).isActive = true
        view.heightAnchor.constraint(lessThanOrEqualToConstant: screen!.height*0.88).isActive = true
        
        bg.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bg.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bg.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bg.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let title = NSTextView()
        title.string = "Life – Loading"
        title.backgroundColor = NSColor.clear
        title.isEditable = false
        title.isSelectable = false
        title.alignment = .center
        title.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        title.font = NSFont.boldSystemFont(ofSize: 25)
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        title.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        title.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        view.addSubview(progressBar)
        progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        progressBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25).isActive = true
        progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        progressBar.startAnimation(self)
        progressBar.isIndeterminate = false
        
    }
    
    
//    override func viewDidAppear() {
//    }
    
}
