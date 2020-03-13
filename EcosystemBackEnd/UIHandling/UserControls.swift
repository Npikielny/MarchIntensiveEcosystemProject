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
import SceneKit

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
	
	func debug() {
        let handler = self.Manager.gameController!.handler
        for i in handler!.foods {
            let Sphere = SCNNode(geometry: SCNSphere(radius: 0.5))
            let color: NSColor = {
                switch i.dataStructure.foodGrowthType {
                case .Fruit:
                    return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0.5134310788)
                case .Meat:
                    return #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 0.4924550514)
                case .Plant:
                    return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5124678938)
                default:
                    return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.5152236729)
                }
            }()
            Sphere.geometry?.materials.first!.diffuse.contents = color
            handler?.Scene.rootNode.addChildNode(Sphere)
            Sphere.worldPosition = i.node.worldPosition
        }
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
