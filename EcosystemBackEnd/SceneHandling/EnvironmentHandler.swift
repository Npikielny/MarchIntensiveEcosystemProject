//
//  PhysicsHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/12/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

func bottom (_ Object: Matter) -> (CGFloat) {return Object.node.worldPosition.y-Object.node.boundingBox.min.y}

class EnvironmentHandler {
    
    var View: SCNView?
    
    var Scene: SCNScene
    
    var water: SurfaceWaterMesh!
    var treeGen: TreeGenerator!
    
    var sky: MDLSkyCubeTexture!
    var time: Float = 0
    var azimuth: Float = 0
    
    var controller: GameController
    
    
    var frameNumber: Int = 0
    
    var mapDimension: CGFloat = 400
    var mapCountDimension: Int = 100
    
    var gen: generator!
    var terrain: Ground!
    
    var dataStorage = [DataPoint]()
    
    lazy var setupFunctions: [(()->(),String)] = [(()->(),String)]()
    var setupFunctionIndex: Int = 0
    var initialized: Bool = false // Necessary to keep animals from moving before startup
    
    var animals: [Animal] = [Animal] () {
        didSet {
            for i in 0..<animals.count {
                if let _ = animals[i].node.parent {}else {
                    self.Scene.rootNode.addChildNode(animals[i].node)
                }
            }
        }
    }
    
    var foods: [Food] = [Food]() {
        didSet {
            for i in 0..<foods.count {
                if let _ = foods[i].node.parent {}else {
                    self.Scene.rootNode.addChildNode(foods[i].node)
                }
                if moveableFoods.contains(where: {$0.node == foods[i].node}) == false && (foods[i].foodGrowthType == .Fruit) || (foods[i].foodGrowthType == .Meat) {
                    moveableFoods.append(foods[i])
                }
            }
        }
    }
    
    var moveableFoods = [Food]()
    
    var selectionIndex: Int? = nil {
        didSet {
            if let _ = selectionIndex {
                if self.selectionIndex! < self.animals.count {
                    self.selectedAnimal = self.animals[self.selectionIndex!]
                }else {
                    self.selectedAnimal = nil
                }
            }else {
                self.selectedAnimal = nil
            }
        }
    }
    
    var selectedAnimal: Animal?
    
    
    init(_ FileNamed: String, InitialNumberOfBunnies: Int, Controller: GameController) {
        self.controller = Controller
        self.Scene = SCNScene(named: FileNamed)!
        var functions = [(()->(),String)]()
        functions.append(({}, "Setting Up SCNScene"))
        functions.append((setupCamera, "Setting Up Camera"))
        functions.append((setupTerrrain, "Adding Terrain"))
        functions.append((classifyVerticies, "Analyzing Terrain"))
        if building == false {
            functions.append((setupLighting, "Adding Lighting and Loading Sky"))
            functions.append((setupWater, "Adding Water"))
            functions.append((setupTrees, "Adding Trees"))
            functions.append((getNames, "Finding Animal Names"))
            functions.append((addAnimals, "Adding Animals"))
            functions.append((addFood, "Adding Food"))
            functions.append((addClouds, "Creating Weather"))
        }
        
        else {
//            setupFunctions.append((debugPoints,"Adding Debugging Points"))
            functions.append((checkPoints,"Check Points"))
        }
        functions.append((commenceEngine, "Starting Physics Engine"))
        setupFunctions = functions
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
    
    var lightSource: SCNNode!
    var skySave: [Float:CGImage?] = [:]
    var skyIndex: Float = 0
    var lastTime: Float = 0
    func setupLighting() {
        lightSource = SCNNode()
        lightSource.light = SCNLight()
        lightSource.light?.type = .directional
        lightSource.worldPosition = SCNVector3(0,0,1).toMagnitude(500)
        lightSource.light?.shadowMode = .forward
        self.Scene.rootNode.addChildNode(lightSource)
        lightSource.name = "LightSource"
        setupSky()
        
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.worldPosition = SCNVector3(0, 100, 0)
        ambientNode.light?.shadowMode = .forward
        
        ambientNode.light?.color = NSColor.white
        ambientNode.light?.intensity = 10
        self.Scene.rootNode.addChildNode(ambientNode)
        ambientNode.name = "Ambient Light"
    }
    
    fileprivate func addClouds() {
        
        for _ in 0...Int.random(in: 20...30) {
            let x = Cloud(RadiusRange: 50...(mapDimension / 2), Spread: 0.5...3.25, VerticalCompressionFactor: 0.3, CloudCount: Int.random(in: 15...20), ScalingFactor: 1)
            self.Scene.rootNode.addChildNode(x.node)
            x.node.worldPosition = x.node.worldPosition.setValue(Component: .y, Value: CGFloat.random(in: 55...75))
        }
        
    }
    
    func setupTerrrain() {
        gen = generator()
        terrain = Ground(width: mapDimension, height: mapDimension, widthCount: mapCountDimension, heightCount: mapCountDimension, Gen: gen) // max rated at 256x256
        terrain.node.name = "Terrain"
        Scene.rootNode.addChildNode(terrain.node)
        self.terrain.node.geometry?.materials.first!.setValue(Float(mapDimension + 30), forKey: "x")
        self.terrain.node.geometry?.materials.first!.setValue(Float(mapDimension + 30), forKey: "z")
    }
    
    func classifyVerticies() {
        viableVerticies = terrain.vertices
        viableVerticies.removeAll(where: {$0.status == .Water || $0.status == .Tree})
        drinkableVertices = terrain.vertices
        drinkableVertices.removeAll(where: {$0.status != .NearWater})
    }
    
    func setupWater() {
        water = SurfaceWaterMesh(width: mapDimension, height: mapDimension, widthCount: mapCountDimension / 4, heightCount: mapCountDimension / 4)
        water.node.name = "Water"
        if building == false {
            Scene.rootNode.addChildNode(water.node)
        }
    }
    
    func setupTrees() {
        let verts = viableVerticies.map({$0.vector})
        treeGen = TreeGenerator(NumberOfPines: 100, Points: verts)
        if building == false {
            for i in treeGen.trees {
                Scene.rootNode.addChildNode(i.node)
            }
        }
    }
    

        func addAnimals() {
            let Diego = Rabbit(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
            Diego.node.name = "Diego"
            Diego.sex = .Male
            let secondRabbit = Rabbit(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
            secondRabbit.sex = .Female

//            let sparrow1 = Sparrow(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
//            sparrow1.sex = .Male
//
//            let sparrow2 = Sparrow(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
//            sparrow2.sex = .Female


            let fox1 = Fox(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
            fox1.sex = .Male
            let fox2 = Fox(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
            fox2.sex = .Female
            
            
            
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
//    
//            for _ in 0..<2 {
//                let pos = self.viableVerticies.randomElement()!.vector
//                let _ = Cactus(Position:  pos.setValue(Component: .y, Value: pos.y), Handler: self)
//            }
        }
    
    func debugPoints() {
        for i in self.terrain.vertices {
            let node = SCNNode(geometry: SCNSphere(radius: 0.3))
            if i.status == .NearWater {
                node.geometry?.materials.first?.diffuse.contents = NSColor.cyan
            }else if i.status == .Water {
                node.geometry?.materials.first?.diffuse.contents = NSColor.blue
            }else if i.status == .Tree {
                node.geometry?.materials.first?.diffuse.contents = NSColor.orange
            }else {
                node.geometry?.materials.first?.diffuse.contents = NSColor.green
            }
            Scene.rootNode.addChildNode(node)
            node.worldPosition = i.vector
        }
    }
    
    func checkPoints() {
        for x in -100...100 {
            for z in -100...100 {
//                let X = Int32((CGFloat(x) * 2 + mapDimension / 2) / mapDimension * CGFloat(mapCountDimension))
//                let Z = Int32((CGFloat(z) * 2 + mapDimension / 2) / mapDimension * CGFloat(mapCountDimension))
                
                let node = SCNNode(geometry: SCNSphere(radius: 0.3))
                let vector = SCNVector3(x: 2 * CGFloat(x), y: 0, z: 2 * CGFloat(z))
                node.worldPosition = vector.setValue(Component: .y, Value: mapValueAt(vector))
//                node.worldPosition = SCNVector3(CGFloat(X) / CGFloat(mapCountDimension) * mapDimension - mapDimension/2,CGFloat(gen.valueFor(x: X, y: Z)),CGFloat(Z) / CGFloat(mapCountDimension) * mapDimension - mapDimension/2)
//                node.worldPosition = SCNVector3(CGFloat(X) / 128 * 400 - 200,5,CGFloat(Z) / 128 * 400 - 200)
                Scene.rootNode.addChildNode(node)
            }
        }
    }
    
    var camera: Camera!
    func setupCamera() {
        self.camera =  Camera(Position: SCNVector3(x: 100, y: 10, z: 100), Target: SCNVector3().zero(), SceneRootNode: self.Scene.rootNode)
        self.camera.node.look(at: SCNVector3().zero())
        self.controller.camera = self.camera
    }

    var statsNode: SCNNode = {
        let text = SCNText(string: "Diego", extrusionDepth: 1)
        text.font = NSFont.systemFont(ofSize: 10)
        let node = SCNNode()
        node.geometry = text
        return node
    }()

    var thirstNode: SCNNode = {
        let geo = SCNCapsule(capRadius: 0.2, height: 3)
        geo.heightSegmentCount = 60
        let node = SCNNode(geometry: geo)
        node.geometry?.materials.first!.setValue(Float(0), forKey: "threshold")
        node.geometry?.materials.first!.shaderModifiers = [.geometry:getShader(from: "waterStatShader")]
        node.geometry?.materials.first!.transparencyMode = .aOne
        return node
    }()

    var hungerNode: SCNNode = {
        let geo = SCNCapsule(capRadius: 0.2, height: 3)
        geo.heightSegmentCount = 60
        let node = SCNNode(geometry: geo)
        node.geometry?.materials.first!.setValue(Float(0), forKey: "threshold")
        node.geometry?.materials.first!.shaderModifiers = [.geometry:getShader(from: "hungerStatShader")]
        node.geometry?.materials.first!.transparencyMode = .aOne
        return node
    }()

    var healthNode: SCNNode = {
        let geo = SCNCapsule(capRadius: 0.2, height: 3)
        geo.heightSegmentCount = 60
        let node = SCNNode(geometry: geo)
        node.geometry?.materials.first!.setValue(Float(0), forKey: "threshold")
        node.geometry?.materials.first!.shaderModifiers = [.geometry:getShader(from: "healthStatShader")]
        node.geometry?.materials.first!.transparencyMode = .aOne
        return node
    }()
    
    var breedNode: SCNNode = {
        let geo = SCNCapsule(capRadius: 0.2, height: 3)
        geo.heightSegmentCount = 60
        let node = SCNNode(geometry: geo)
        node.geometry?.materials.first!.setValue(Float(0), forKey: "threshold")
        node.geometry?.materials.first!.shaderModifiers = [.geometry:getShader(from: "breedingStatShader")]
        node.geometry?.materials.first!.transparencyMode = .aOne
        return node
    }()
    
    var targetNode: SCNNode = {
        let node = SCNNode()
        node.geometry = SCNSphere(radius: 0.3)
        node.geometry?.materials.first?.diffuse.contents = NSColor.orange
        return node
    }()
    
    func Physics() {
        let difference = Float(1)/Float(30)
        for item in moveableFoods {
            
            let nodeShift = item.node.boundingBox.min.y
            
            let heightMap = mapValueAt(item.node.worldPosition)
            let heightInit = item.node.worldPosition.y + nodeShift
            
            if heightInit > heightMap {
                item.acceleration += SCNVector3(0,-1 * 9.807,0)
            }
            item.velocity += item.acceleration.scalarMultiplication(Scalar: CGFloat(difference))
            item.node.worldPosition += item.velocity.scalarMultiplication(Scalar: CGFloat(difference))
            
            let height = item.node.worldPosition.y + nodeShift
            if height <= heightMap {
                item.velocity = SCNVector3(0,0,0)
                item.node.worldPosition = item.node.worldPosition.setValue(Component: .y, Value: heightMap - nodeShift)
            }
            item.acceleration = SCNVector3(0,0,0)
        }
        
        for item in animals {
            if item.inProcess {
                item.velocity = item.velocity.setValue(Component: .z, Value: 0)
                item.velocity = item.velocity.setValue(Component: .x, Value: 0)
            }
            let nodeShift = item.node.boundingBox.min.y
            
            let heightMap = mapValueAt(item.node.worldPosition)
            let heightInit = item.node.worldPosition.y + nodeShift
            
            if heightInit > heightMap {
                item.acceleration += SCNVector3(0,-1 * 9.807,0)
            }
            item.velocity += item.acceleration.scalarMultiplication(Scalar: CGFloat(difference))
            item.node.worldPosition += item.velocity.scalarMultiplication(Scalar: CGFloat(difference))
            
            let height = item.node.worldPosition.y + nodeShift
            if height <= heightMap {
                item.velocity = SCNVector3(0,0,0)
                item.node.worldPosition = item.node.worldPosition.setValue(Component: .y, Value: heightMap - nodeShift)
                if item.inProcess && item.priority == .Breed {
                    item.velocity = SCNVector3(0,item.Speed,0)
                }
            }
            item.acceleration = SCNVector3(0,0,0)
        }
        
        lastTime = self.time
    }
    
    func commenceEngine() {
        self.initialized = true
        self.Scene.rootNode.addChildNode(thirstNode)
        self.Scene.rootNode.addChildNode(hungerNode)
        self.Scene.rootNode.addChildNode(healthNode)
        self.Scene.rootNode.addChildNode(statsNode)
        self.Scene.rootNode.addChildNode(breedNode)
        self.Scene.rootNode.addChildNode(targetNode)

        self.thirstNode.isHidden = true
        self.hungerNode.isHidden = true
        self.healthNode.isHidden = true
        self.statsNode.isHidden = true
        self.breedNode.isHidden = true
        self.targetNode.isHidden = true
    }
    
    func process() {
        if self.frameNumber % 30*50*40 == 0 {
            self.collectData()
        }
        self.frameNumber += 1
        if self.initialized {
            if building == false {
                for i in animals {
                    i.movementHandler()
                }
                
                for i in foods {
                    if (i.foodGrowthType != .Fruit || i.foodGrowthType != .Meat) && foods.count < 150 { //Mark: Cap – maybe want to remove later
                        i.reproductionChance()
                    }
                }
                
                newPlants()
                selectionhandling()
            }
//            cameraMovement()
        }
    }
    
    fileprivate func newPlants() {
//        if Int.random(in: 0..<30*25) == 0 {
//            _ = Apple(Position: self.viableVerticies.randomElement()!.vector.setValue(Component: .y, Value: 10), Handler: self)
//        }
//        
//        if Int.random(in: 0..<30*25*4) == 0 {
//            let vector = self.viableVerticies.randomElement()!.vector
//            _ = Daisy(Position: vector.setValue(Component: .y, Value: mapValueAt(vector)), Handler: self)
//        }
//        
//        if Int.random(in: 0..<30*25*4) == 0 {
//            let vector = self.viableVerticies.randomElement()!.vector
//            _ = Grass(Position: vector.setValue(Component: .y, Value: mapValueAt(vector)), Handler: self)
//        }
    }
    
    fileprivate func selectionhandling() {
        if let _ = self.terrain {
            if let individual = self.selectedAnimal {
                self.terrain.node.geometry?.materials.first!.setValue(Float(individual.node.worldPosition.x), forKey: "x")
                self.terrain.node.geometry?.materials.first!.setValue(Float(individual.node.worldPosition.z), forKey: "z")
                setStats()
                self.thirstNode.isHidden = false
                self.hungerNode.isHidden = false
                self.healthNode.isHidden = false
                self.statsNode.isHidden = false
                self.breedNode.isHidden = false
                self.targetNode.isHidden = false
            }else {
                self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "x")
                self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "z")
                self.thirstNode.isHidden = true
                self.hungerNode.isHidden = true
                self.healthNode.isHidden = true
                self.statsNode.isHidden = true
                self.breedNode.isHidden = true
                self.targetNode.isHidden = true
            }
        }
    }
    
//    fileprivate func cameraMovement() {
//        if self.camera.cameraType == .following {
//            if let animal = self.selectedAnimal {
//                self.camera.node.position = (animal.node.worldPosition - animal.velocity).setValue(Component: .y, Value: 10) + (SCNVector3(x: 5, y: 0, z: 5))
//                self.camera.node.look(at: animal.node.worldPosition)
//            }
//        }
//    }
    

    func collectData() {
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
