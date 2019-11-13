//
//  PhysicsHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/12/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class EnvironmentHandler {
    
    var Scene: SCNScene
    
    init(_ FileNamed: String) {
        self.Scene = SCNScene(named: FileNamed)!
        setupPhysics()
//        self.Scene.
        setupLighting()
    }
    var sky: MDLSkyCubeTexture!
    func setupLighting() {
        sky = MDLSkyCubeTexture(name: nil,
                                    channelEncoding: MDLTextureChannelEncoding.uInt8,
                                    textureDimensions: [Int32(160), Int32(160)],
                                    turbidity: 0.750,
                                    sunElevation: 0.500,
                                    upperAtmosphereScattering: 0.150,
                                    groundAlbedo: 0.850)
        let material = SCNMaterial()
        material.shininess = 0.15
        material.fresnelExponent = 0.25
        
        material.specular.contents = NSColor.white
        material.diffuse.contents =  NSColor.darkGray
        
        sky.update()
        
        self.Scene.background.contents = (sky.imageFromTexture())?.takeUnretainedValue()
//        let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime() {
        sky.sunAzimuth += 0.1
        sky.update()
        self.Scene.background.contents = (sky.imageFromTexture())?.takeUnretainedValue()
    }
    
    func setupPhysics() {
        setupTerrrain()
        
        let movingPine = Pine(Position: SCNVector3(0, 100, 0))
        movingPine.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: movingPine.node, options: [:]))
        movingPine.node.name = "MOVING PINE"
        movingPine.node.worldPosition = SCNVector3(0, 100, 0)
        Scene.rootNode.addChildNode(movingPine.node)
    }
    
    func setupTerrrain() {
            
        let ground = SceneGenerator()
        
        Scene.rootNode.addChildNode(ground.ground.node)
        Scene.rootNode.addChildNode(ground.water.node)
        for i in ground.pineGen.pines {
            Scene.rootNode.addChildNode(i.node)
            i.node.name = "PineTree"
        }
        
    }
    
    func handlePhyiscs() {
        
    }
    
    
    
}
