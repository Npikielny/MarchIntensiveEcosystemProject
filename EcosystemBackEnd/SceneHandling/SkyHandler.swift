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
        
        updateTime()
        pushSky()
    }
    
    func updateTime() {
        time += Float.pi/90000
        if building == true {
            time = Float.pi/4
        }
        sky.sunElevation = sin(time)/2+0.5
        
        if sky.sunElevation > 0 {
            sky.brightness = pow(sin(time),3)/2
        }else {
            sky.brightness = -1*pow(abs(sin(time)),(1/256/256))
        }
        sky.upperAtmosphereScattering = sin(time)/6+0.17
        sky.groundAlbedo = sin(time)/4+0.3
        sky.turbidity = pow(cos(time),4)
        
        if (sky.sunElevation == 1) || (sky.sunElevation == 0) {
            sky.sunAzimuth += Float.pi
        }
        
        if Int((time/Float.pi)*90000) % 500 == 0 && building == false {
            pushSky()
        }
        if let _ = lightSource {
            lightSource.worldPosition = SCNVector3(0,sin(time),cos(time)).toMagnitude(500)
            lightSource.look(at: SCNVector3().zero())
        }
    }
    
    func pushSky() {
        sky.update()
        self.Scene.background.contents = (sky.imageFromTexture())?.takeUnretainedValue()
    }
}