//
//  SkyHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/16/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

extension EnvironmentHandler {
    
    func setupSky() {
        sky = MDLSkyCubeTexture(name: nil,
                                    channelEncoding: MDLTextureChannelEncoding.uInt8,
                                    textureDimensions: [Int32(160), Int32(160)],
                                    turbidity: 0.250,
                                    sunElevation: 0.500,
                                    upperAtmosphereScattering: 0.150,
                                    groundAlbedo: 0.850)
        
        saveSkys()
        updateTime()
        setSky(Index: 0)
    }
    
    func updateTime() {
        time += Float.pi/90000
//        if building == true {
//            time = Float.pi/4
//        }
//        sky.sunElevation = sin(time)/2+0.5
//
//        if sky.sunElevation > 0 {
//            sky.brightness = pow(sin(time),3)/2
//        }else {
//            sky.brightness = -1*pow(abs(sin(time)),(1/256/256))
//        }
//        sky.upperAtmosphereScattering = sin(time)/6+0.17
//        sky.groundAlbedo = sin(time)/4+0.3
//        sky.turbidity = pow(cos(time),4)
//
//        if (sky.sunElevation == 1) || (sky.sunElevation == 0) {
//            sky.sunAzimuth += Float.pi
//        }
//
        if Int((time/Float.pi)*90000) % 2500 == 0 && building == false {
            self.skyIndex += 1
//            self.skyIndex -= Float(Int(self.skyIndex) % 36)
            if self.skyIndex >= 36 {
                self.skyIndex = 0
            }
            self.setSky(Index: self.skyIndex)
        }
        if let _ = lightSource {
            lightSource.worldPosition = SCNVector3(0,sin(time),cos(time)).toMagnitude(500)
            lightSource.look(at: SCNVector3().zero())
        }
    }
    
    func saveSkys() {
        for i in 0..<72 {
            let index = 2*Float.pi/36*Float(i)
            sky.sunElevation = sin(index)/2+0.5
            
            if sky.sunElevation > 0 {
                sky.brightness = pow(sin(index),3)/2
            }else {
                sky.brightness = -1*pow(abs(sin(index)),(1/256/256))
            }
            sky.upperAtmosphereScattering = sin(index)/6+0.17
            sky.groundAlbedo = sin(index)/4+0.3
            sky.turbidity = pow(cos(index),4)
            
            if (sky.sunElevation == 1) || (sky.sunElevation == 0) {
                sky.sunAzimuth += Float.pi
            }
            sky.update()
            let texture = sky.imageFromTexture()
            self.skySave[Float(i)] = texture?.takeUnretainedValue()
            
        }
    }
    
    func setSky(Index: Float) {
//        self.Scene.background.contents = (sky.imageFromTexture())?.takeUnretainedValue()
        self.Scene.background.contents = self.skySave[Index]
    }
}
