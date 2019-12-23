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
        text.textColor = NSColor.white
        
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
            let sexSTR:String = {
                if self.Manager.gameController?.handler.selectedAnimal?.sex == .Male {
                    return " ♂"
                }else {
                    return " ♀"
                }
            }()
            self.Name.font = NSFont.systemFont(ofSize: 20)
            self.Name.string = (self.Manager.gameController?.handler.selectedAnimal!.node.name)! + sexSTR
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
        if let animal = self.Manager.gameController?.handler.selectedAnimal {
            let sexSTR:String = {
                if animal.sex == .Male {
                    return " ♂"
                }else {
                    return " ♀"
                }
            }()
            self.Name.string = (animal.node.name)! + sexSTR
        }
    }
    
    var dataCollectionButton: NSButton = {
        let button = NSButton(title: "Collect Data", target: self, action: #selector(printData))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func printData() {
		
//        print("Animals")
//        for i in (self.Manager.gameController?.handler.animalDataStorage)! {
//            print(i)
//        }
//        print("Plants")
//        for i in (self.Manager.gameController?.handler.foodDataStorage)!{
//            print(i)
//        }
		
		createCSV()
		
    }
    
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	
	func createCSV() {
		let currentDate = Date()
		let fileName = "\(currentDate)-EcosystemData.csv"
//		let path = FileManager.default.homeDirectoryForCurrentUser
        
        let name = fileName
       let fileManager = FileManager.default
       let documentDirectory = try! fileManager.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
       let fileURL = documentDirectory.appendingPathComponent(name)
        
		
		var csvText = "Time, Animals, Plants\n"
        
        for index in 0..<self.Manager.gameController!.handler.animalDataStorage.count {
            csvText.append(String(index)+","+String(self.Manager.gameController!.handler.animalDataStorage[index])+","+String(self.Manager.gameController!.handler.foodDataStorage[index])+"\n")
        }
		
		do {
			try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
			print("Created CSV named \(fileURL)")
		} catch {
			print("Could not save CSV")
			print(error)
		}
		
		
		
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
        
        view.addSubview(dataCollectionButton)
        dataCollectionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        dataCollectionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        
        
    }
    
    
}
