//
//  SimulationController.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 12/21/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import Cocoa

class SimulationController: NSViewController {
    
    convenience init() {
        self.init(nibName: "SimulationController", bundle: nil)
    }
    
    let bunnyOutputText: NSTextView = {
        let tv = NSTextView()
        tv.string = "Number of Bunnies: "
        tv.font = NSFont.systemFont(ofSize: 15)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = NSColor.white
        tv.backgroundColor = NSColor.clear
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    let foodOutputText: NSTextView = {
        let tv = NSTextView()
        tv.string = "Number of Food Items: "
        tv.font = NSFont.systemFont(ofSize: 15)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = NSColor.white
        tv.backgroundColor = NSColor.clear
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    var runSimulationButton: NSButton = {
        let button = NSButton(title: "Run Simulation", target: self, action: #selector(runSimulation))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var simulation = SimulationHandler(NumberOfStartingBunnies: 2, MapSideLength: 400)
    
    @objc func runSimulation() {
        simulation.runSimulation()
        print("Finished Metal")
        for i in simulation.animals {
            print(i.node.worldPosition)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.addSubview(bunnyOutputText)
        view.addSubview(foodOutputText)
        
        bunnyOutputText.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bunnyOutputText.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        bunnyOutputText.widthAnchor.constraint(equalToConstant: 200).isActive = true
        bunnyOutputText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        foodOutputText.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        foodOutputText.topAnchor.constraint(equalTo: bunnyOutputText.topAnchor, constant: 40).isActive = true
        foodOutputText.widthAnchor.constraint(equalToConstant: 200).isActive = true
        foodOutputText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(runSimulationButton)
        runSimulationButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        runSimulationButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        while simulation.setupFunctionIndex < simulation.setupFunctions.count {
            print(simulation.setupFunctions[simulation.setupFunctionIndex].1)
            simulation.runSetupFunction()
        }
        
    }
    
}
