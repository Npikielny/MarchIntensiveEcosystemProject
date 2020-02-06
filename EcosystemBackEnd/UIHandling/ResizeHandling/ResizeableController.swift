//
//  ResizeableController.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 2/6/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class ResizeableController: NSViewController {

    convenience init () {
        self.init(nibName: "ResizeableController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func resizeWindow(to Frame: NSSize) {
        
    }
    
}
