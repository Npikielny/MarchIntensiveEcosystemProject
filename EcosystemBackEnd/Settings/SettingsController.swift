//
//  SettingsController.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 3/13/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class SettingsController: NSViewController {

    convenience init() {
        self.init(nibName: "SettingsController", bundle: nil)
    }
    
    let backgroundView: NSImageView = {
        let imView = NSImageView()
        imView.wantsLayer = true
        imView.translatesAutoresizingMaskIntoConstraints = false
        return imView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.addSubview(backgroundView)
        backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
}


