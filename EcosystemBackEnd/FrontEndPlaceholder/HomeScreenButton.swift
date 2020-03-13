//
//  Home Screen Buttons.swift
//  EcosystemFrontEnd
//
//  Created by Christopher Lee on 11/20/19.
//  Copyright © 2019 Christopher Lee. All rights reserved.
//

import Cocoa

class HomeScreenButton: NSButton {
	
	var mouseIsOver: Bool = false
    
	override init(frame: NSRect) {
		super.init(frame: frame)
		
		configureButton()
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configureButton() {
		
		self.cell = HomeScreenButtonCell()
		self.cell?.controlView?.layer?.masksToBounds = false
		self.cell?.controlView?.layer?.cornerRadius = 25
		self.state = .off
		self.isBordered = false
		self.wantsLayer = true
		self.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.50).cgColor
		self.layer?.masksToBounds = false
		self.layer?.cornerRadius = 25
		self.bezelStyle = .smallSquare
		
	}
	
}

class HomeScreenButtonCell: NSButtonCell {
	
	override func highlight(_ flag: Bool, withFrame cellFrame: NSRect, in controlView: NSView) {

		if self.isHighlighted == false {
			controlView.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.90).cgColor
			self.isHighlighted = true
		}
		else {
			controlView.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.75).cgColor
			self.isHighlighted = false
		}

	}
	
}
