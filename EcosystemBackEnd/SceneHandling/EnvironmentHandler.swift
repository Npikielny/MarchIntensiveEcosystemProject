//
//  PhysicsHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/12/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

func bottom (_ Object: Matter) -> (CGFloat) {return Object.node.worldPosition.y+Object.node.boundingBox.min.y}

class EnvironmentHandler: SimulationBase {
    
    var View: SCNView?
    
    var Scene: SCNScene
    
    var water: SurfaceWaterMesh!
    var treeGen: TreeGenerator!
    
    var sky: MDLSkyCubeTexture!
        var time: Float = 0
        var azimuth: Float = 0
    
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
    
    
    init(_ FileNamed: String, InitialNumberOfBunnies: Int) {
        self.Scene = SCNScene(named: FileNamed)!
        super.init(Handler: true)
        setupFunctions.append(({}, "Setting Up SCNScene"))
        setupFunctions.append((setupLighting, "Adding Lighting and Loading Sky"))
        setupFunctions.append((setupTerrrain, "Adding Terrain"))
        setupFunctions.append((setupWater, "Adding Water"))
        setupFunctions.append((setupTrees, "Adding Trees"))
        setupFunctions.append((classifyVerticies, "Preparing Scene For Life"))
        setupFunctions.append((getNames, "Finding Animal Names"))
        setupFunctions.append((addAnimals, "Adding Animals"))
//        setupFunctions.append((addFood, "Adding Food"))
//        setupFunctions.append((debugPoints,"Adding Debugging Points"))
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
        self.Scene.rootNode.addChildNode(lightSource)
        lightSource.name = "LightSource"
        setupSky()
        
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.worldPosition = SCNVector3(0, 100, 0)
        
        ambientNode.light?.color = NSColor.white
        ambientNode.light?.intensity = 100
        self.Scene.rootNode.addChildNode(ambientNode)
        ambientNode.name = "Ambient Light"
    }
    
    override func setupTerrrain() {
        
        terrain = Ground(width: 400, height: 400, widthCount: 100, heightCount: 100)
        terrain.node.name = "Terrain"
        Scene.rootNode.addChildNode(terrain.node)
        self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "x")
        self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "z")
    }
    
    func setupWater() {
        water = SurfaceWaterMesh(width: 400, height: 400, widthCount: 25, heightCount: 25)
        water.node.name = "Water"
        if building == false {
            Scene.rootNode.addChildNode(water.node)
        }
    }
    
    func setupTrees() {
        treeGen = TreeGenerator(NumberOfPines: 200, Points: &terrain.vertices)
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
            
            lastTime = self.time
        }
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
            for i in animals {
                i.movementHandler()
            }
//            for _ in foods {
//                if Int.random(in: 0..<30*50*40) == 0 {
//                    _ = Apple(Position: self.viableVerticies.randomElement()!.vector.setValue(Component: .y, Value: 10), Handler: self)
//                }
//            }
            if Int.random(in: 0..<30*25) == 0 {
                _ = Apple(Position: self.viableVerticies.randomElement()!.vector.setValue(Component: .y, Value: 10), Handler: self)
            }
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
    }
    
}
