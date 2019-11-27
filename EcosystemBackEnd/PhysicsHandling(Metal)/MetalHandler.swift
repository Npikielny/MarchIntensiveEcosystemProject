//
//  MetalHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/26/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

struct animalData {
    var position: SCNVector3
    var velocity: SCNVector3
    var heightOfMap: Float
    var direction: CGFloat = 0
    var id: Int32
    static let size = MemoryLayout<animalData>.stride
}
extension EnvironmentHandler {
    func getIndividualAnimalData(animal: Animal) -> animalData {
        let heightMap = animal.handler.terrain.noiseMap
        let coords = (animal.node.worldPosition.x/400,animal.node.worldPosition.y/400)
        return animalData(position: animal.node.worldPosition, velocity: animal.velocity, heightOfMap: Float(1), id: animal.Id)
    }

    func getAnimalData(Animals: [Animal]) -> [animalData] {
        var data = [animalData]()
        for i in Animals {
            data.append(getIndividualAnimalData(animal: i))
        }
        return data
    }

    func syncIndividual(animal: Animal, data: animalData) {
        animal.node.worldPosition = data.position
        animal.velocity = data.velocity
        animal.node.eulerAngles = SCNVector3(0, data.direction, 0)
    }
    
    func syncData(Buffer: UnsafeMutablePointer<animalData>) {
        for i in 0..<animals.count {
            let data = Buffer[i]
            let index = animals.firstIndex(where: {$0.Id == data.id})
            if let indexFound = index {
                let individual = animals[indexFound]
                print(data.position.y)
                syncIndividual(animal: individual, data: data)
            }
        }
    }
    
    func handleMetal() {
        let data = getAnimalData(Animals: self.animals)
        
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
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(1, 1, 1)

        commandEncoder.dispatchThreadgroups(MTLSize(width: data.count, height: 1, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        commandBuffer!.commit()
        commandBuffer!.waitUntilCompleted()
        
        syncData(Buffer: buffer.contents().bindMemory(to: animalData.self, capacity: animals.count))
    }
}
