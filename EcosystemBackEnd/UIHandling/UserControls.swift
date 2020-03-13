//
//  UserControls.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/28/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

class UserControls: NSViewController, ObservableObject {

    var Manager: WindowManager!
    
	var updateSliders = Timer()
	
    convenience init() {
        self.init(nibName: "UserControls", bundle: nil)
    }
	
	@Published var animalCount: Int = 0
	@Published var foodCount: Int = 0
	@Published var animalList: [Animal] = []
	
//	@Published var name: String = ""
//	@Published var sex: String = ""
//	@Published var species: String = ""
//
	@Published var foodType: String = ""
	@Published var priority: String = ""
//	@Published var age: Float = 0
//	@Published var speed: CGFloat = 0
//	@Published var efficiency: CGFloat = 0
//
//	@Published var health: Float = 0
//	@Published var thirst: Float = 0
//	@Published var hunger: Float = 0
//	@Published var breedingUrge: Float = 0
//	@Published var maxHealth: Float = 0
//	@Published var maxThirst: Float = 0
//	@Published var maxHunger: Float = 0
//	@Published var maxBreedingUrge: Float = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		let hostingView = NSHostingView(rootView: UserControlsView(userControls: self))
		
		self.view.addSubview(hostingView)
		hostingView.translatesAutoresizingMaskIntoConstraints = false
		hostingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//		animalCollectionView.register(AnimalCVItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "item"))
		
		startTimer()
		
    }
	
	@objc func createCSV() {
		
		let currentDate = Date()
		let fileName = "\(currentDate)-EcosystemData.csv"
        
        let name = fileName
		let fileManager = FileManager.default
		let documentDirectory = try! fileManager.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
		let fileURL = documentDirectory.appendingPathComponent(name)
        
		
		var csvText = "Frames, Animals, Plants\n"
        
        for index in self.Manager.gameController!.handler.dataStorage {
            let str: String = {
                let p1: String = String(index.FrameNumber)
                let p2: String = String(index.AnimalCount)
                let p3: String = String(index.FoodCount)
                return p1+","+p2+","+p3+"\n"
            }() //For compile time
            csvText.append(str)
        }
		
		do {
			try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
			print("Created CSV named \(fileURL)")
		} catch {
			print("Could not save CSV")
			print(error)
		}
		
	}
    
    var grapherWindow: SizeableWindow?
    
    @objc func createGraph() {
        if let _ = grapherWindow {
            let cont = grapherWindow?.controller as! GraphController
            cont.setData(self.Manager.gameController!.handler!.dataStorage)
            self.grapherWindow!.makeKeyAndOrderFront(self)
        }else {
            let controller = GraphController()
            let window = SizeableWindow(contentViewController: controller)
            window.controller = controller
            window.makeKeyAndOrderFront(self)
            controller.setData(self.Manager.gameController!.handler!.dataStorage)
            grapherWindow = window
        }
    }
	
	private func startTimer() {
		updateSliders = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateStats), userInfo: nil, repeats: true)
	}
	
	@objc func updateStats() {
		self.animalCount = self.Manager.gameController?.handler.animals.count ?? 0
		self.foodCount = self.Manager.gameController?.handler.foods.count ?? 0
		
		self.animalList = self.Manager.gameController?.handler.animals ?? []
		
//		self.health = self.Manager.gameController?.handler.selectedAnimal?.health ?? 0
//		self.thirst = self.Manager.gameController?.handler.selectedAnimal?.thirst ?? 0
//		self.hunger = self.Manager.gameController?.handler.selectedAnimal?.hunger ?? 0
//		self.breedingUrge = self.Manager.gameController?.handler.selectedAnimal?.breedingUrge ?? 0
		
		switch self.Manager.gameController?.handler.selectedAnimal?.speciesData.foodType {
		case .Omnivore:
			self.foodType = "Omnivore"
		case .Meat:
			self.foodType = "Meat"
		case .Fruit:
			self.foodType = "Fruit"
		case .Plant:
			self.foodType = "Plant"
		case .Producer:
			self.foodType = "Producer"
		case .Vegetarian:
			self.foodType = "Vegetarian"
		case .none:
			self.foodType = "N/A"
		}
		
		switch self.Manager.gameController?.handler.selectedAnimal?.priority {
		case .Food:
			self.priority = "Food"
		case .Water:
			self.priority = "Water"
		case .Breed:
			self.priority = "Breed"
		case .Idle:
			self.priority = "Idle"
		case .Flee:
			self.priority = "Flee"
		case .none:
			self.priority = "N/A"
		}
		
	}
    
}

extension UserControls: NSCollectionViewDelegate, NSCollectionViewDataSource {
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.Manager.gameController?.handler.animals.count ?? 0
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		
		
		
		return collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "item"), for: indexPath)
	}
	
	
	
	
}
