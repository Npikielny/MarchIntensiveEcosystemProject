//
//  UserControls.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/28/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa

class UserControls: NSViewController {

    var Manager: WindowManager!
    
    convenience init() {
        self.init(nibName: "UserControls", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        setupViews()
    }
    
    var Name: NSText = {
        let text = NSText()
        text.font = NSFont.systemFont(ofSize: 20)
        text.string = "Name: "
        text.alignment = .center
        
        text.backgroundColor = NSColor.clear
        
        text.isSelectable = false
        text.isEditable = false
        
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    lazy var nextButton = NSButton(image: NSImage(named: NSImage.goRightTemplateName)!, target: self, action: #selector(nextAnimal))
    lazy var previousButton = NSButton(image: NSImage(named: NSImage.goLeftTemplateName)!, target: self, action: #selector(previousAnimal))
    
    var animalIndex: Int?
    @objc func nextAnimal() {
        if let _ = animalIndex {
            self.animalIndex! += 1
            if animalIndex! >= self.Manager.gameController!.handler.animals.count {
                self.animalIndex = 0
            }
        }else {
            self.animalIndex = 0
        }
        self.Manager.gameController?.handler.selectionIndex = self.animalIndex!
        if let _ = self.Manager.gameController?.handler.selectedAnimal {
            self.Name.string = "Name: " + (self.Manager.gameController?.handler.selectedAnimal!.node.name)!
        }else {
            self.Name.string = "No Animal Selected"
        }
    }
    
    @objc func previousAnimal() {
        if let _ = animalIndex {
            animalIndex! -= 1
            if animalIndex! < 0 {
                animalIndex = self.Manager.gameController!.handler.animals.count - 1
            }
        }else {
            animalIndex = 0
        }
        self.Manager.gameController?.handler.selectionIndex = self.animalIndex!
        self.Name.string = "Name: " + (self.Manager.gameController?.handler.selectedAnimal!.node.name)!
    }
    
    func setupViews() {
        view.addSubview(Name)
        
        Name.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        Name.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        Name.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8).isActive = true
        Name.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nextButton.leftAnchor.constraint(equalTo: Name.rightAnchor, constant: 5).isActive = true
        nextButton.topAnchor.constraint(equalTo: Name.topAnchor).isActive = true
        nextButton.heightAnchor.constraint(equalTo: Name.heightAnchor, multiplier: 1).isActive = true
        
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previousButton)
        
        previousButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        previousButton.rightAnchor.constraint(equalTo: Name.leftAnchor, constant: -5).isActive = true
        previousButton.topAnchor.constraint(equalTo: Name.topAnchor).isActive = true
        previousButton.heightAnchor.constraint(equalTo: Name.heightAnchor, multiplier: 1).isActive = true
    }
    
    
}
