//
//  PhysicsHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/12/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

func bottom (_ Object: Matter) -> (CGFloat) {return Object.node.worldPosition.y-Object.node.boundingBox.min.y}

class EnvironmentHandler: SimulationBase {
    
    var View: SCNView?
    
    var Scene: SCNScene
    
    var water: SurfaceWaterMesh!
    var treeGen: TreeGenerator!
    
    var sky: MDLSkyCubeTexture!
    var time: Float = 0
    var azimuth: Float = 0
    
    var controller: GameController
    
    override var animals: [Animal] {
        didSet {
            for i in 0..<animals.count {
                if let _ = animals[i].node.parent {}else {
                    self.Scene.rootNode.addChildNode(animals[i].node)
                }
            }
        }
    }
    
    override var foods: [Food] {
        didSet {
            for i in 0..<foods.count {
                if let _ = foods[i].node.parent {}else {
                    self.Scene.rootNode.addChildNode(foods[i].node)
                }
                if movableFoods.contains(where: {$0.node == foods[i].node}) == false && foods[i].foodType != .Plant {
                    movableFoods.append(foods[i])
                }
            }
        }
    }
    
    var selectionIndex: Int? = nil {
        didSet {
            if let _ = selectionIndex {
                if self.selectionIndex! < self.animals.count {
                    self.selectedAnimal = self.animals[self.selectionIndex!]
                }else {
                    self.selectedAnimal = nil
                }
            }else {
                if self.animals.count > 0 {
                    self.selectionIndex = 0
                }else {
                    self.selectedAnimal = nil
                }
            }
        }
    }
    
    var selectedAnimal: Animal?
    
    
    init(_ FileNamed: String, InitialNumberOfBunnies: Int, Controller: GameController) {
        self.controller = Controller
        self.Scene = SCNScene(named: FileNamed)!
        super.init(Handler: true)
        setupFunctions.append(({}, "Setting Up SCNScene"))
        setupFunctions.append((setupCamera, "Setting Up Camera"))
        setupFunctions.append((setupTerrrain, "Adding Terrain"))
        setupFunctions.append((classifyVerticies, "Analyzing Terrain"))
        if building == false {
            setupFunctions.append((setupLighting, "Adding Lighting and Loading Sky"))
            setupFunctions.append((setupWater, "Adding Water"))
            setupFunctions.append((setupTrees, "Adding Trees"))
            setupFunctions.append((getNames, "Finding Animal Names"))
            setupFunctions.append((addAnimals, "Adding Animals"))
            setupFunctions.append((addFood, "Adding Food"))
            setupFunctions.append((addClouds, "Creating Weather"))
        }
        
        else {
//            setupFunctions.append((debugPoints,"Adding Debugging Points"))
            setupFunctions.append((checkPoints,"Check Points"))
        }
        setupFunctions.append((commenceEngine, "Starting Physics Engine"))
    }
    
    
    var lightSource: SCNNode!
    var skySave: [Float:CGImage?] = [:]
    var skyIndex: Float = 0
    func setupLighting() {
        lightSource = SCNNode()
        lightSource.light = SCNLight()
        lightSource.light?.type = .directional
        lightSource.worldPosition = SCNVector3(0,0,1).toMagnitude(500)
        lightSource.light?.shadowMode = .forward
        self.Scene.rootNode.addChildNode(lightSource)
        lightSource.name = "LightSource"
        setupSky()
        
//        let ambientNode = SCNNode()
//        ambientNode.light = SCNLight()
//        ambientNode.light?.type = .ambient
//        ambientNode.worldPosition = SCNVector3(0, 100, 0)
//        ambientNode.light?.shadowMode = .forward
//        
//        ambientNode.light?.color = NSColor.white
//        ambientNode.light?.intensity = 100
//        self.Scene.rootNode.addChildNode(ambientNode)
//        ambientNode.name = "Ambient Light"
    }
    
    fileprivate func addClouds() {
        
        for _ in 0...Int.random(in: 20...30) {
            let x = Cloud(RadiusRange: 50...(mapDimension / 2), Spread: 0.5...3.25, VerticalCompressionFactor: 0.3, CloudCount: Int.random(in: 15...20))
            self.Scene.rootNode.addChildNode(x.node)
            x.node.worldPosition = x.node.worldPosition.setValue(Component: .y, Value: CGFloat.random(in: 25...35))
        }
        
    }
    
    override func setupTerrrain() {
        gen = generator()
        terrain = Ground(width: mapDimension, height: mapDimension, widthCount: mapCountDimension, heightCount: mapCountDimension, Gen: gen) // max rated at 256x256
        terrain.node.name = "Terrain"
        Scene.rootNode.addChildNode(terrain.node)
        self.terrain.node.geometry?.materials.first!.setValue(Float(mapDimension + 30), forKey: "x")
        self.terrain.node.geometry?.materials.first!.setValue(Float(mapDimension + 30), forKey: "z")
    }
    
    override func classifyVerticies() {
        viableVerticies = terrain.vertices
        viableVerticies.removeAll(where: {$0.status != .Normal && $0.status != .NearWater})
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
        treeGen = TreeGenerator(NumberOfPines: 100, Points: viableVerticies.map({$0.vector}))
        if building == false {
            for i in treeGen.trees {
                Scene.rootNode.addChildNode(i.node)
            }
        }
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
    
    override func Physics() {
        let difference = Float(1)/Float(30)
        
        for item in animals+movableFoods {
            item.acceleration = SCNVector3(0,0,0)
            
            let nodeShift = item.node.boundingBox.min.y
            
            let heightMap = mapValueAt(item.node.worldPosition)
            let heightInit = item.node.worldPosition.y + nodeShift
            
            if heightInit > heightMap {
                item.acceleration += SCNVector3(0,-1 * 9.807,0)
            }
            item.velocity += item.acceleration.scalarMultiplication(Scalar: CGFloat(difference))
            item.node.worldPosition += item.velocity.scalarMultiplication(Scalar: CGFloat(difference))
            
            let height = item.node.worldPosition.y + nodeShift
            if height <= heightMap{
                item.velocity = SCNVector3(0,0,0)
                item.node.worldPosition = item.node.worldPosition.setValue(Component: .y, Value: heightMap - nodeShift)
            }
        }
        
//        for item in animals+movableFoods {
//            item.acceleration = SCNVector3().zero()
//            let heightMap = mapValueAt(item.node.worldPosition)
//            if bottom(item) > heightMap {
//                item.acceleration -= SCNVector3(0,CGFloat(difference * 9.807),0)
//            }else if bottom(item) < heightMap {
//                item.node.worldPosition = item.node.worldPosition.setValue(Component: .y, Value: heightMap - item.node.boundingBox.min.y)
//            }
//            if bottom(item) - heightMap < 0.1 && item.velocity.y < 0 {
//                item.velocity = SCNVector3().zero()
//            }
//            item.velocity += item.acceleration.scalarMultiplication(Scalar: CGFloat(difference))
//            item.node.worldPosition += item.velocity.scalarMultiplication(Scalar: CGFloat(difference))
//        }
//
//        for item in animals {
//            item.acceleration = SCNVector3().zero()
////            let bm = CGFloat(gen.valueFor(x: Int32(item.node.worldPosition.x / 400*128), y: Int32(item.node.worldPosition.z / 400*128)))
//            let Bm = mapValueAt(item.node.worldPosition)
//            let btm = item.node.boundingBox.min.y
//            item.node.worldPosition = item.node.worldPosition.setValue(Component: .y, Value: Bm - btm)
//        }
        
        lastTime = self.time
    }
    
    override func commenceEngine() {
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
    
    override func process() {
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
                    if i.foodType == .Plant && foods.count < 150 { //Mark: Cap – maybe want to remove later
                        i.reproductionChance()
                    }
                }
                
                newPlants()
                selectionhandling()
            }
            cameraMovement()
        }
    }
    
    fileprivate func newPlants() {
        if Int.random(in: 0..<30*25) == 0 {
            _ = Apple(Position: self.viableVerticies.randomElement()!.vector.setValue(Component: .y, Value: 10), Handler: self)
        }
        
        if Int.random(in: 0..<30*25*4) == 0 {
            let vector = self.viableVerticies.randomElement()!.vector
            _ = Daisy(Position: vector.setValue(Component: .y, Value: mapValueAt(vector)), Handler: self)
        }
        
        if Int.random(in: 0..<30*25*4) == 0 {
            let vector = self.viableVerticies.randomElement()!.vector
            _ = Grass(Position: vector.setValue(Component: .y, Value: mapValueAt(vector)), Handler: self)
        }
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
    
    fileprivate func cameraMovement() {
        if self.camera.cameraType == .following {
            if let animal = self.selectedAnimal {
                self.camera.node.position = (animal.node.worldPosition - animal.velocity).setValue(Component: .y, Value: 10) + (SCNVector3(x: 5, y: 0, z: 5))
                self.camera.node.look(at: animal.node.worldPosition)
            }
        }
    }
    
}
