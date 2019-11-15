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
    
    init(_ FileNamed: String) {
        self.Scene = EnvironmentScene(named: FileNamed)!
        setupPhysics()
        setupLighting()
        addAnimals()
    }
    var sky: MDLSkyCubeTexture!
    var lightSource: SCNNode!
    func setupLighting() {
        sky = MDLSkyCubeTexture(name: nil,
                                    channelEncoding: MDLTextureChannelEncoding.uInt8,
                                    textureDimensions: [Int32(160), Int32(160)],
                                    turbidity: 0.750,
                                    sunElevation: 0.500,
                                    upperAtmosphereScattering: 0.150,
                                    groundAlbedo: 0.850)
        
        updateTime()
        pushSky()
        
        lightSource = SCNNode()
        lightSource.light = SCNLight()
        lightSource.light?.type = .directional
        lightSource.worldPosition = SCNVector3(1,0,0).toMagnitude(1000)
        self.Scene.rootNode.addChildNode(lightSource)
        lightSource.name = "LightSource"
        
    }
    var time: Float = 0
    var azimuth: Float = Float.pi/2
    func updateTime() {
        time += Float.pi/90000
        sky.sunElevation = sin(time)
        if abs(sky.sunElevation) == 1 {
            azimuth += Float.pi
        }
        sky.brightness = (1+sky.sunElevation)/2
        sky.sunAzimuth = azimuth
        if Int((time/Float.pi)*90000) % 500 == 0 {
            pushSky()
        }
        if let _ = lightSource {
            lightSource.worldPosition = SCNVector3(cos(time),sin(time),0).toMagnitude(500)
            lightSource.look(at: SCNVector3().zero())
        }
    }
    
    func pushSky() {
//        print("L")
        sky.update()
        self.Scene.background.contents = (sky.imageFromTexture())?.takeUnretainedValue()
    }
    
    func setupPhysics() {
        setupTerrrain()
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
    
    func addAnimals() {
//        let rabbit = Rabbit(Position: SCNVector3(10,10,0))
//        Scene.rootNode.addChildNode(rabbit.node)
        
    }
    
}

