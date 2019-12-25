//
//  simulationBase.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 12/21/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class SimulationBase {

    var frameNumber: Int = 0
    
    var terrain: Ground!
    
    var animalDataStorage = [Int]()
    var foodDataStorage = [Int]()
    
    lazy var setupFunctions: [(()->(),String)] = [(()->(),String)]()
    var setupFunctionIndex: Int = 0
    var initialized: Bool = false // Necessary to keep animals from moving before startup
    
    
    init(Handler: Bool) {
        if Handler {}else {
            setupFunctions.append(({}, "Setting Up SCNScene"))
            setupFunctions.append((setupTerrrain, "Adding Terrain"))
            setupFunctions.append((classifyVerticies, "Preparing Scene For Life"))
            setupFunctions.append((getNames, "Finding Animal Names"))
            setupFunctions.append((addAnimals, "Adding Animals"))
            setupFunctions.append((addFood, "Adding Food"))
            setupFunctions.append((commenceEngine, "Starting Physics Engine"))
        }
    }
    
    var Names: [String]!
    
    func getNames() {
        guard let filepath = Bundle.main.path(forResource: "PetNames", ofType: "csv")
            else {
                fatalError("FailedtoFindPath")
        }
        
        
        let contents = try! String(contentsOfFile: filepath)
        var nems = contents.components(separatedBy: ",")
        nems = nems.map({$0.lowercased()})
        nems = nems.map({$0.capitalized})
        
        self.Names = nems
    }
    
    func runSetupFunction() {
        if setupFunctionIndex < setupFunctions.count {
            (setupFunctions[setupFunctionIndex].0)()
            setupFunctionIndex += 1
        }else {
            fatalError("Index Out of Range")
        }
    }
    
    var viableVerticies: [SpaciallyAwareVector]!
    var drinkableVertices: [SpaciallyAwareVector]!
    func setupTerrrain() {
        terrain = Ground(width: 400, height: 400, widthCount: 100, heightCount: 100)
        terrain.node.name = "Terrain"
        self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "x")
        self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "z")
    }
    
    func classifyVerticies() {
        viableVerticies = terrain.vertices
        viableVerticies.removeAll(where: {$0.status != .Normal && $0.status != .NearWater})
        drinkableVertices = terrain.vertices
        drinkableVertices.removeAll(where: {$0.status != .NearWater})
    }
    
    func addAnimals() {
        let Diego = Rabbit(Position: SCNVector3(0,10,0), Handler: self)
        Diego.node.name = "Diego"
        Diego.sex = .Male
        let secondRabbit = Rabbit(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
        secondRabbit.sex = .Female
//        for _ in 0..<2-1 {
//            let _ = Rabbit(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
//        }
        
    }
    
    func addFood() {
        for _ in 0..<10 {
            let i = Daisy(Position: self.viableVerticies.randomElement()!.vector.setValue(Component: .y, Value: 2), Handler: self)
            let height = i.node.boundingBox.min.y
            i.node.worldPosition = i.node.worldPosition.setValue(Component: .y, Value: 2 - height)
        }
    }
    
    var animals = [Animal]()
    var foods = [Food]()
    var movableFoods = [Food]()
    
    var lastTime: Float = 0
    func Physics() {
        var foodList = foods
        foodList.removeAll(where: {$0.foodType == .Plant})
        if self.initialized {
            let difference = Float(1)/Float(10)
            for item in animals+foods {
                item.acceleration = SCNVector3().zero()
                if bottom(item) > 2 {
                    item.acceleration -= SCNVector3().initOfComponent(Component: .y, Value: CGFloat(9.807*difference))
                }else if bottom(item) < 2 {
                    item.node.worldPosition = item.node.worldPosition.setValue(Component: .y, Value: 2-item.node.boundingBox.min.y)
                }
                if bottom(item) - 2 < 0.005 && item.velocity.y < 0 {
                    item.velocity = SCNVector3().zero()
                }
                item.velocity += item.acceleration.scalarMultiplication(Scalar: CGFloat(difference))
                item.node.worldPosition += item.velocity.scalarMultiplication(Scalar: CGFloat(difference))
            }
        }
    }
    
    func commenceEngine() {
        self.initialized = true
    }
        
    func process() {
        if self.frameNumber % 30*50*40 == 0 {
            self.collectData()
        }
        self.frameNumber += 1
//        if self.initialized {
//            for i in animals {
//                i.movementHandler()
//            }
//            for i in foods {
//                if i.foodType == .Plant {
//                    if Int.random(in: 0..<30*50) == 0 {
//                        let i = Daisy(Position: self.viableVerticies.randomElement()!.vector.setValue(Component: .y, Value: 2), Handler: self)
//                        let height = i.node.boundingBox.min.y
//                        i.node.worldPosition = i.node.worldPosition.setValue(Component: .y, Value: 2 - height)
//                    }
//                }
//            }
//        }
    }
    
    func collectData() {
        self.animalDataStorage.append(self.animals.count)
        self.foodDataStorage.append(self.foods.count)
    }
    
}
