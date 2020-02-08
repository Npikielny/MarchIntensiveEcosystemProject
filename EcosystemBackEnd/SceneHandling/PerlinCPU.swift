//
//  PerlinCPU.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 2/7/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//
import Foundation

class generator {
    
    var noiseX: Int = 1619
    var noiseY: Int = 31337
    var noiseSeed: Int = 1013
    var seed: Int = 1
    
    private func interpolate(a: Double, b: Double, x: Double) ->Double {
            let ft: Double = x * Double.pi
            let f: Double = (1.0-cos(ft)) * 0.5
            
            return a*(1.0-f)+b*f
        }
     
     
     private func findNoise(x: Double, y: Double) ->Double {
        var n = (noiseX*Int(x) +
                 noiseY*Int(y) +
                 noiseSeed * seed) & 0x7fffffff
        
        n = (n >> 13) ^ n // from 2^32 to 2^13
        n = (n &* (n &* n &* 60493 + 19990303) + 1376312589) & 0x7fffffff
        
        return 1.0 - Double(n)/1073741824
    }

    // -------------------------------------------------------------------------

    private func noise(x: Double, y: Double) ->Double {
        let floorX: Double = Double(Int(x))
        let floorY: Double = Double(Int(y))
        
        let s = findNoise(x:floorX, y:floorY)
        let t = findNoise(x:floorX+1, y:floorY)
        let u = findNoise(x:floorX, y:floorY+1)
        let v = findNoise(x:floorX+1, y:floorY+1)
        
        let i1 = interpolate(a:s, b:t, x:x-floorX)
        let i2 = interpolate(a:u, b:v, x:x-floorX)
        
        return interpolate(a:i1, b:i2, x:y-floorY)
    }

    // -------------------------------------------------------------------------
    // MARK: - Calculate a noise value for x,y

    func valueFor(x: Int32, y: Int32) ->Double {
        let octaves = 3
        let p: Double = 1/2
        let zoom: Double = 12
        var getnoise: Double = 0
        
        for a in 0..<octaves-1 {
            let frequency = pow(2, Double(a))
            let amplitude = pow(p, Double(a))
            
            getnoise += noise(x:(Double(x))*frequency/zoom, y:(Double(y))/zoom*frequency)*amplitude
        }
        
        var value: Double = Double(((getnoise*128.0)+128.0))
        
        if (value > 255) {
            value = 255
        }
        else if (value < 0) {
            value = 0
        }
        if (value/255 * 5 - 0.5) <= 1.6 {
            return (value/255 * 5 - 0.5) - 2
        }else {
            return value/255 * 5 - 0.5
        }
    }

}
