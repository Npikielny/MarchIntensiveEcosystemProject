//
//  SimulationHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 12/21/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class SimulationHandler: SimulationBase {
    init(NumberOfStartingBunnies: Int, MapSideLength: CGFloat) {
        super.init(Handler: false)
    }
    
    func runSimulation() {
        process()
        handleMetal()
    }
    
    
    
    
    
    func handleMetal() {
        var data = [animalData]()
        for i in self.animals {
            data.append(animalData(AnimalData: i))
        }
        
        var pipeline: MTLComputePipelineState!
        let device:MTLDevice = MTLCreateSystemDefaultDevice()!
        let library = device.makeDefaultLibrary()
        let commandQueue = device.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()

        let buffer = device.makeBuffer(bytes: data, length: animalData.size*data.count, options: [])!

        let commandEncoder = (commandBuffer?.makeComputeCommandEncoder())!
        let function = library?.makeFunction(name: "calculatePhysics")!
        pipeline = try! device.makeComputePipelineState(function: function!)
        commandEncoder.setComputePipelineState(pipeline)
        commandEncoder.setBuffer(buffer, offset: 0, index: 0)

        let w = pipeline.threadExecutionWidth
        
        let threadsPerThreadgroup = MTLSizeMake(1, 1, 1)

        commandEncoder.dispatchThreadgroups(MTLSize(width: data.count, height: 1, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        commandBuffer!.commit()
        commandBuffer!.waitUntilCompleted()

        syncData(Buffer: buffer.contents().bindMemory(to: animalData.self, capacity: animals.count))
    }
    
    func syncData(Buffer: UnsafeMutablePointer<animalData>) {
        for i in 0..<animals.count {
            let data = Buffer[i]
            let index = animals.firstIndex(where: {$0.Id == data.id})
            if let indexFound = index {
                syncIndividual(animal: &animals[indexFound], data: data)
            }
        }
    }
    func syncIndividual(animal: inout Animal, data: animalData) {
        animal.node.worldPosition = data.position
    }
    
    override func Physics() {
        for i in foods {
            i.node.worldPosition = i.node.worldPosition.zero(.y)
        }
        for item in animals {
            if item.node.worldPosition.y > 0 {
                item.node.worldPosition = item.node.worldPosition.zero(.y)
            }
        }
    }
    
    override func process() {
        if self.frameNumber % 30*50*40 == 0 {
            self.collectData()
        }
        self.frameNumber += 1
        for i in 0..<animals.count {
            syntheticMovementHandler(animal: &animals[i])
        }
        for _ in foods {
            if Int.random(in: 0..<30*50*40/32) == 0 {
                _ = Apple(Position: self.viableVerticies.randomElement()!.vector.setValue(Component: .y, Value: 10), Handler: self)
            }
        }
        if Int.random(in: 0..<30*50*40/4/8) == 0 {
            _ = Apple(Position: self.viableVerticies.randomElement()!.vector.setValue(Component: .y, Value: 10), Handler: self)
        }
    }
    
    func syntheticMovementHandler(animal: inout Animal) {
        
    }
    
}

struct animalData {
    var position: SCNVector3
    var target: SCNVector3
    var age: Float
    var maxSpeed: Float
    var hunger: Float
    var thirst: Float
    var health: Float
    var breedingUrge: Float
    var waiting: Bool
    var id: Int
    static let size = MemoryLayout<animalData>.stride
    init(AnimalData: Animal) {
        self.position = AnimalData.node.worldPosition
        self.target = AnimalData.target
        self.age = AnimalData.age
        self.maxSpeed = Float(AnimalData.Speed)
        self.hunger = AnimalData.hunger
        self.thirst = AnimalData.thirst
        self.health = AnimalData.health
        self.breedingUrge = AnimalData.breedingUrge
        if AnimalData.inProcess {
            self.waiting = true
        }else {
            self.waiting = false
        }
        self.id = Int(AnimalData.Id)
    }
}
