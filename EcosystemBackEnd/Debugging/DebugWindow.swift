//
//  DebugWindow.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/15/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa

class DebugWindow: NSViewController {
    
    
//    turbidity: 0.750,
//    sunElevation: 0.500,
//    upperAtmosphereScattering: 0.150,
//    groundAlbedo: 0.850
    
    
    @IBOutlet weak var TurbidityLabel: NSTextField!
    @IBOutlet weak var turbidityValue: NSSlider!
    @IBAction func changeTurbidity(_ sender: Any) {
        TurbidityLabel.stringValue = String(turbidityValue.floatValue)
    }
    
    @IBOutlet weak var ElevationLabel: NSTextField!
    @IBOutlet weak var ElevationValue: NSSlider!
    @IBAction func changeElevation(_ sender: Any) {
        ElevationLabel.stringValue = String(ElevationValue.floatValue)
    }
    
    @IBOutlet weak var ScatteringLabel: NSTextField!
    @IBOutlet weak var scatteringValue: NSSlider!
    @IBAction func changeScattering(_ sender: Any) {
        ScatteringLabel.stringValue = String(scatteringValue.floatValue)
    }
    
    
    @IBOutlet weak var AlbedoLabel: NSTextField!
    @IBOutlet weak var albedoValue: NSSlider!
    @IBAction func changeAlbedo(_ sender: Any) {
        AlbedoLabel.stringValue = String(albedoValue.floatValue)
    }
    
    @IBAction func PushSky(_ sender: Any) {
        MainScene.sky.turbidity = turbidityValue.floatValue
        MainScene.sky.sunElevation = ElevationValue.floatValue
        MainScene.sky.upperAtmosphereScattering = scatteringValue.floatValue
        MainScene.sky.groundAlbedo = albedoValue.floatValue
    }
    
    
    
    convenience init () {
        self.init(nibName: "DebugWindow", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    
    
    
}
