//
//  PhysicsHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/12/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class EnvironmentHandler {
    
    var Scene: EnvironmentScene
    var Environment: SceneGenerator!
    
    var sky: MDLSkyCubeTexture!
        var time: Float = 0
        var azimuth: Float = 0
        
    init(_ FileNamed: String) {
        self.Scene = EnvironmentScene(named: FileNamed)!
        setupPhysics()
        setupLighting()
        setupTerrrain()
        addAnimals()
        MainScene = self
//        debugPoints()
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
    }
    
    func setupPhysics() {
        
    }
    
    var viableVerticies: [SpaciallyAwareVector]!
    func setupTerrrain() {
            
        Environment = SceneGenerator()
        
        Scene.rootNode.addChildNode(Environment.ground.node)
        if building == false {
            Scene.rootNode.addChildNode(Environment.water.node)
            for i in Environment.treeGen.trees {
                Scene.rootNode.addChildNode(i.node)
            }
        }
        viableVerticies = Environment.ground.vertices
        viableVerticies.removeAll(where: {$0.status != .Normal && $0.status != .NearWater})
    }
    
    func addAnimals() {
        let Diego = Rabbit(Position: SCNVector3(0,10,0), Handler: self)
        Diego.node.name = "Diego"
        Scene.rootNode.addChildNode(Diego.node)
        
        for i in 0..<25-1 {
            let rabbit = Rabbit(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 10), Handler: self)
            Scene.rootNode.addChildNode(rabbit.node)
        }
        
        for _ in 0..<50 {
            let apple = Apple(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat.random(in: 0...200)).setValue(Component: .y, Value: 20), Handler: self)
            apple.addPhysicsBody()
            self.Scene.rootNode.addChildNode(apple.node)
        }
    }
    
    func debugPoints() {
        for i in self.Environment.ground.vertices {
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
    
    var animals = [Animal]()
    var foods = [Food]()
    
}


class SceneGenerator {
    var ground: Ground
    var water: SurfaceWaterMesh
    var treeGen: TreeGenerator
    init() {
        ground = Ground(width: 400, height: 400, widthCount: 100, heightCount: 100)
        ground.node.name = "Terrain"
        water = SurfaceWaterMesh(width: 400, height: 400, widthCount: 25, heightCount: 25)
        water.node.name = "Water"
        treeGen = TreeGenerator(NumberOfPines: 200, Points: &ground.vertices)
    }

}
