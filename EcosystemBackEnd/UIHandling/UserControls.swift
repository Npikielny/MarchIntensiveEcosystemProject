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
    
	var updateSliders = Timer()
	
    convenience init() {
        self.init(nibName: "UserControls", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        setupViews()
		startTimer()
		
    }
    
    var nameText: NSText = {
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
	
	var thirstText: NSText = {
		let text = NSText()
		text.font = NSFont.systemFont(ofSize: 12)
		text.string = "Thirst:  "
        text.backgroundColor = NSColor.clear
		text.alignment = .center
		text.textColor = .white
		text.isSelectable = false
		text.isEditable = false
		text.translatesAutoresizingMaskIntoConstraints = false
		return text
	}()
	
	var thirstSlider: NSSlider = {
		let slider = NSSlider()
		let cell = CustomSliderCell()
		cell.activeColor = .blue
		slider.cell = cell
		slider.sliderType = .linear
		slider.minValue = 0
		slider.maxValue = 100
        slider.floatValue = 50
		slider.translatesAutoresizingMaskIntoConstraints = false
		return slider
	}()
	
	var hungerText: NSText = {
		let text = NSText()
		text.font = NSFont.systemFont(ofSize: 12)
		text.string = "Hunger:  "
        text.backgroundColor = NSColor.clear
		text.alignment = .center
		text.textColor = .white
		text.isSelectable = false
		text.isEditable = false
		text.translatesAutoresizingMaskIntoConstraints = false
		return text
	}()
	
	var hungerSlider: NSSlider = {
		let slider = NSSlider()
		let cell = CustomSliderCell()
		cell.activeColor = .systemOrange
		slider.cell = cell
		slider.sliderType = .linear
		slider.minValue = 0
		slider.maxValue = 100
        slider.floatValue = 50
		slider.translatesAutoresizingMaskIntoConstraints = false
		return slider
	}()
	
	var healthText: NSText = {
		let text = NSText()
		text.font = NSFont.systemFont(ofSize: 12)
		text.string = "Health:  "
        text.backgroundColor = NSColor.clear
		text.alignment = .center
		text.textColor = .white
		text.isSelectable = false
		text.isEditable = false
		text.translatesAutoresizingMaskIntoConstraints = false
		return text
	}()
	
	var healthSlider: NSSlider = {
		let slider = NSSlider()
		let cell = CustomSliderCell()
		cell.activeColor = .systemGreen
		slider.cell = cell
		slider.sliderType = .linear
		slider.minValue = 0
		slider.maxValue = 100
        slider.floatValue = 50
		slider.translatesAutoresizingMaskIntoConstraints = false
		return slider
	}()
	
	var breedingText: NSText = {
		let text = NSText()
		text.font = NSFont.systemFont(ofSize: 12)
		text.string = "Breeding Urge:  "
        text.backgroundColor = NSColor.clear
		text.alignment = .center
		text.textColor = .white
		text.isSelectable = false
		text.isEditable = false
		text.translatesAutoresizingMaskIntoConstraints = false
		return text
	}()
	
	var breedingSlider: NSSlider = {
		let slider = NSSlider()
		let cell = CustomSliderCell()
		cell.activeColor = .magenta
		slider.cell = cell
		slider.sliderType = .linear
		slider.minValue = 0
		slider.maxValue = 100
        slider.floatValue = 50
		slider.translatesAutoresizingMaskIntoConstraints = false
		return slider
	}()
	
    lazy var nextButton = NSButton(image: NSImage(named: NSImage.goRightTemplateName)!, target: self, action: #selector(nextAnimal))
    lazy var previousButton = NSButton(image: NSImage(named: NSImage.goLeftTemplateName)!, target: self, action: #selector(previousAnimal))
	lazy var dataCollectionButton: NSButton = {
		let button = NSButton(title: "Collect Data", target: self, action: #selector(createCSV))
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

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
            self.nameText.font = NSFont.systemFont(ofSize: 20)
            self.nameText.string = (self.Manager.gameController?.handler.selectedAnimal!.node.name)! + sexSTR
        }else {
            self.nameText.string = "No Animal Selected"
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
            self.nameText.string = (animal.node.name)! + sexSTR
        }
    }
    
    
    
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	
	@objc func createCSV() {
		
		let currentDate = Date()
		let fileName = "\(currentDate)-EcosystemData.csv"
        
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
	
	private func startTimer() {
		updateSliders = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateStats), userInfo: nil, repeats: true)
	}
	
	@objc func updateStats() {
        if let animal = self.Manager.gameController?.handler.selectedAnimal {
			self.thirstSlider.doubleValue = Double(animal.thirst)
			self.hungerSlider.doubleValue = Double(animal.hunger)
			self.healthSlider.doubleValue = Double(animal.health)
			self.breedingSlider.doubleValue = 100-Double(animal.breedingUrge)
        }
	}
	
    func setupViews() {
		
		[nameText, nextButton, previousButton, dataCollectionButton, thirstText, thirstSlider, hungerText, hungerSlider, healthText, healthSlider, breedingText, breedingSlider].forEach { view.addSubview($0) }
        
        nameText.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        nameText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameText.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8).isActive = true
        nameText.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nextButton.leftAnchor.constraint(equalTo: nameText.rightAnchor, constant: 5).isActive = true
        nextButton.topAnchor.constraint(equalTo: nameText.topAnchor).isActive = true
        nextButton.heightAnchor.constraint(equalTo: nameText.heightAnchor, multiplier: 1).isActive = true
        
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        previousButton.rightAnchor.constraint(equalTo: nameText.leftAnchor, constant: -5).isActive = true
        previousButton.topAnchor.constraint(equalTo: nameText.topAnchor).isActive = true
        previousButton.heightAnchor.constraint(equalTo: nameText.heightAnchor, multiplier: 1).isActive = true
		
		dataCollectionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        dataCollectionButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        dataCollectionButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        dataCollectionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
		
		thirstText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
		thirstText.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.4).isActive = true
		thirstText.topAnchor.constraint(equalTo: nameText.bottomAnchor, constant: 50).isActive = true
		thirstText.bottomAnchor.constraint(equalTo: thirstSlider.bottomAnchor).isActive = true
		
		thirstSlider.topAnchor.constraint(equalTo: thirstText.topAnchor).isActive = true
		thirstSlider.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.6).isActive = true
		thirstSlider.leadingAnchor.constraint(equalTo: thirstText.trailingAnchor, constant: 40).isActive = true
		thirstSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
		
		hungerText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
		hungerText.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.4).isActive = true
		hungerText.topAnchor.constraint(equalTo: thirstText.bottomAnchor, constant: 25).isActive = true
		hungerText.bottomAnchor.constraint(equalTo: hungerSlider.bottomAnchor).isActive = true
		
		hungerSlider.topAnchor.constraint(equalTo: hungerText.topAnchor).isActive = true
		hungerSlider.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.6).isActive = true
		hungerSlider.leadingAnchor.constraint(equalTo: hungerText.trailingAnchor, constant: 40).isActive = true
		hungerSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
		
		healthText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
		healthText.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.4).isActive = true
		healthText.topAnchor.constraint(equalTo: hungerText.bottomAnchor, constant: 25).isActive = true
		healthText.bottomAnchor.constraint(equalTo: healthSlider.bottomAnchor).isActive = true
		
		healthSlider.topAnchor.constraint(equalTo: healthText.topAnchor).isActive = true
		healthSlider.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.6).isActive = true
		healthSlider.leadingAnchor.constraint(equalTo: healthText.trailingAnchor, constant: 40).isActive = true
		healthSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
		
		breedingText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
		breedingText.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.4).isActive = true
		breedingText.topAnchor.constraint(equalTo: healthText.bottomAnchor, constant: 25).isActive = true
		breedingText.bottomAnchor.constraint(equalTo: breedingSlider.bottomAnchor).isActive = true
		
		breedingSlider.topAnchor.constraint(equalTo: breedingText.topAnchor).isActive = true
		breedingSlider.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.6).isActive = true
		breedingSlider.leadingAnchor.constraint(equalTo: breedingText.trailingAnchor, constant: 40).isActive = true
		breedingSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        
    }
    
    
}
