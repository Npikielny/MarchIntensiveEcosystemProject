//
//  SizeableWindow.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 2/6/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class SizeableWindow: NSWindow, NSWindowDelegate {
    var controller: ResizeableController?
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        if let _ = self.controller {
            self.controller!.resizeWindow(to: frameSize)
        }
        return frameSize
    }
}
