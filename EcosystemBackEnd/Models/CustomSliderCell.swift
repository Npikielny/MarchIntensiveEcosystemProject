//
//  CustomSliderCell.swift
//  EcosystemBackEnd
//
//  Created by Christopher Lee on 12/23/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa

class CustomSliderCell: NSSliderCell {
	
	var activeColor: NSColor = .red
	var bgColor: NSColor = .systemGray
	
	override func drawBar(inside rect: NSRect, flipped: Bool) {
		var rect = rect
        rect.size.height = CGFloat(5)
        let barRadius = CGFloat(2.5)
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))
        var leftRect = rect
        leftRect.size.width = finalWidth
		let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
		bgColor.setFill()
		bg.fill()
        let active = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
		activeColor.setFill()
        active.fill()
	}
    
    override func drawKnob() {
        
    }
	
	

}
