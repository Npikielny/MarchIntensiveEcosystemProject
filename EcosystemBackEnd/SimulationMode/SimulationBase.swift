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
    
    var mapDimension: CGFloat = 400
    var mapCountDimension: Int = 100
    
    var gen: generator!
    var terrain: Ground!
    
    var dataStorage = [DataPoint]()
    
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
            setupFunctions.append((debugAnimals,"Reading Initial Conditions"))
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
        gen = generator()
        terrain = Ground(width: mapDimension, height: mapDimension, widthCount: mapCountDimension, heightCount: mapCountDimension, Gen: gen)
        terrain.node.name = "Terrain"
        self.terrain.node.geometry?.materials.first!.setValue(Float(mapDimension + 30), forKey: "x")
        self.terrain.node.geometry?.materials.first!.setValue(Float(mapDimension + 30), forKey: "z")
    }
    
    func classifyVerticies() {
        viableVerticies = terrain.vertices
        print(viableVerticies.map({$0.status}))
        viableVerticies.removeAll(where: {$0.status != .Normal && $0.status != .NearWater})
        drinkableVertices = terrain.vertices
        drinkableVertices.removeAll(where: {$0.status != .NearWater})
    }
    
    func addAnimals() {
        let Diego = Rabbit(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
        Diego.node.name = "Diego"
        Diego.sex = .Male
        let secondRabbit = Rabbit(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
        secondRabbit.sex = .Female
        
        let sparrow1 = Sparrow(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
        sparrow1.sex = .Male
        
        let sparrow2 = Sparrow(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
        sparrow2.sex = .Female
        
//        let x = Fox(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
//        for _ in 0..<2-1 {
//            let _ = Rabbit(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
//        }
        
    }
    
    func addFood() {
        for _ in 0..<10 {
            let pos = self.viableVerticies.randomElement()!.vector
            let _ = Daisy(Position: pos.setValue(Component: .y, Value: pos.y), Handler: self)
        }
        for _ in 0..<30 {
            let pos = self.viableVerticies.randomElement()!.vector
            let _ = Grass(Position:  pos.setValue(Component: .y, Value: pos.y), Handler: self)
        }

        for _ in 0..<5 {
            let pos = self.viableVerticies.randomElement()!.vector
            let _ = BerryBush(Position:  pos.setValue(Component: .y, Value: pos.y), Handler: self)
        }
        
        
//
//        for _ in 0..<2 {
//            let pos = self.viableVerticies.randomElement()!.vector
//            let _ = Cactus(Position:  pos.setValue(Component: .y, Value: pos.y), Handler: self)
//        }
    }
    
    func debugAnimals() {
        for i in self.animals {
            print(i.node.worldPosition)
        }
    }
    
    var animals = [Animal]()
    var foods = [Food]()
    var movableFoods = [Food]()
    
    var lastTime: Float = 0
    func Physics() {
    }
    
    func commenceEngine() {
        self.initialized = true
    }
        
    func process() {
        if self.frameNumber % 30*50*40 == 0 {
            self.collectData()
        }
        self.frameNumber += 1
    }
    
    func collectData() {
//        self.animalDataStorage.append(self.animals.count)
//        self.foodDataStorage.append(self.foods.count)
        var foodPoints: Float = 0
        for i in self.foods {
            foodPoints += (i.foodValue) / 100
        }
        self.dataStorage.append(DataPoint(FoodCount: Int(foodPoints), AnimalCount: self.animals.count, FrameNumber: self.frameNumber))
    }
    
}

struct DataPoint {
    var FoodCount: Int
    var AnimalCount: Int
    var FrameNumber: Int
}
