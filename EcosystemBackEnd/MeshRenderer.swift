//
//  MeshRenderer.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/10/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit
import GameplayKit

extension GameViewController {
    func renderMesh(Scene: SCNScene) {
//        let ground = Ground(width: 400, height: 400, widthCount: 100, heightCount: 100)
//        ground.node.name = "GROUND"
//        Scene.rootNode.addChildNode(ground.node)
//        print(ground.node.boundingBox.max,ground.node.boundingBox.min)
//        let ocean = SurfaceWaterMesh(width: 400, height: 400, widthCount: 10, heightCount: 10)
//
//        Scene.rootNode.addChildNode(ocean.node)
//        ocean.INIT_TIMER()
        
        
        let ground = SceneGenerator()
//        let ground = SceneGenerator(width: 400, height: 400, widthCount: 100, heightCount: 100)
        Scene.rootNode.addChildNode(ground.ground.node)
        Scene.rootNode.addChildNode(ground.water.node)
        
        for i in ground.pineGen.pines {
            Scene.rootNode.addChildNode(i.node)
            i.node.name = "PineTree"
        }
        
    }
}

class Mesh {
    
    var Verticies: [SCNVector3]
    var Indicies: [UInt16]
    var node: SCNNode!
    
    lazy var source = {return SCNGeometrySource(vertices: self.Verticies)}
    lazy var element = {return SCNGeometryElement(indices: self.Indicies, primitiveType: SCNGeometryPrimitiveType.triangles)}
    
    init(Verticies: [SCNVector3], Indices: [UInt16]) {
        self.Verticies = Verticies
        self.Indicies = Indices
        makeMesh()
        
    }
    
    func makeMesh() {
        if let _ = self.node {
            self.node.geometry = SCNGeometry(sources: [self.source()], elements: [self.element()])
        }else {
            self.node = SCNNode(geometry: SCNGeometry(sources: [self.source()], elements: [self.element()]))
        }
        customizeMesh()
    }
    
    func customizeMesh() {}
    
    
    
}

class SceneGenerator {
    var ground: Ground
    var water: SurfaceWaterMesh
    var pineGen: PineGenerator
    init() {
        ground = Ground(width: 400, height: 400, widthCount: 100, heightCount: 100)
        ground.node.name = "Terrain"
//        water = SurfaceWaterMesh(width: 400, height: 400, widthCount: 25, heightCount: 25, NoiseMap: ground.noiseMap, Threshold: 5, NoiseMapWidth: 100, NoiseMapHeight: 100)
        water = SurfaceWaterMesh(width: 400, height: 400, widthCount: 25, heightCount: 25)
        water.node.name = "Water"
        pineGen = PineGenerator(NumberOfPines: 500, NoiseMap: ground.noiseMap, Width: 400, Height: 400, widthCount: 100, heightCount: 100)
    }

}

//class SceneGenerator {
//    var ground: Mesh
//    var water: Mesh
//    var pineGen: PineGenerator
//    var noiseMap: GKNoiseMap
////    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int) {
////        var vertices = [SCNVector3]()
////            noiseMap = {
////                let source = GKPerlinNoiseSource()
////                source.persistence = 0.9
////                let noise = GKNoise(source)
////                let size = vector2(1.0, 1.0)
////                let origin = vector2(0.0, 0.0)
////                let sampleCount = vector2(Int32(widthCount), Int32(heightCount))
////                return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
////            }()
////            for w in 0..<widthCount {
////                for h in 0..<heightCount {
////                    let vertex = SCNVector3(x: width*CGFloat(w)/CGFloat(widthCount-1)-width/2, y: 1-CGFloat(noiseMap.interpolatedValue(at: vector_float2(Float(w),Float(h)))), z: height*CGFloat(h)/CGFloat(heightCount-1)-height/2)
////                    vertices.append(vertex)
////                }
////            }
////
////            var groundIndices = [UInt16]()
////            var waterIndices = [UInt16]()
////
////            let index: (Int,Int) -> Int = {return $0 * heightCount + $1}
////
////
////            for w in 0..<widthCount-1 {
////                for h in 0..<heightCount-1 {
////                    var squareVerticies = [UInt16]()
////                    squareVerticies.append(UInt16(index(w,h)))
////                    squareVerticies.append(UInt16(index(w,h+1)))
////                    squareVerticies.append(UInt16(index(w+1,h)))
////                    squareVerticies.append(UInt16(index(w+1,h+1)))
////
////                    var water: Bool = false
////
////                    for i in [index(w,h),index(w,h+1),index(w+1,h),index(w+1,h+1)] {
////                        if vertices[i].y < 2 {
////                            water = true
////                        }
////                    }
////
////                    groundIndices.append(squareVerticies[0])
////                    groundIndices.append(squareVerticies[1])
////                    groundIndices.append(squareVerticies[3])
////
////                    groundIndices.append(squareVerticies[0])
////                    groundIndices.append(squareVerticies[3])
////                    groundIndices.append(squareVerticies[2])
////
////                    if water == true {
////                        waterIndices.append(squareVerticies[0])
////                        waterIndices.append(squareVerticies[1])
////                        waterIndices.append(squareVerticies[3])
////
////                        waterIndices.append(squareVerticies[0])
////                        waterIndices.append(squareVerticies[3])
////                        waterIndices.append(squareVerticies[2])
////                    }
////
////                }
////            }
////        ground = Mesh(Verticies: vertices, Indices: groundIndices)
////        ground.node.name = "Ground"
////        let color1: NSColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
////        let color2: NSColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
////        ground.node.geometry?.materials.first?.roughness.contents = 1
////        ground.node.geometry?.materials.first!.shaderModifiers = [.geometry :
////            getShader(from: "groundShader")
////        ]
////
////
////
////
////
////        water = Mesh(Verticies: vertices, Indices: waterIndices)
////        water.node.name = "Water"
////
////        let color: NSColor = #colorLiteral(red: 0, green: 0.9859127402, blue: 1, alpha: 0.5554098887)
////        water.node.geometry?.materials.first!.diffuse.contents = color
////        water.node.geometry?.materials.first?.metalness.contents = 1
////        water.node.geometry?.materials.first?.roughness.contents = 0
////        water.node.geometry?.materials.first?.multiply.contents = NSColor.white
////        water.node.geometry?.materials.first?.shininess = 1
////        water.node.geometry?.materials.first?.specular.contents = 1
////        water.node.geometry?.materials.first!.shaderModifiers = [.geometry :
////            getShader(from: "waterShader")
////        ]
////
////
////
////
////        pineGen = PineGenerator(NumberOfPines: 500, NoiseMap: noiseMap, Width: 400, Height: 400, widthCount: 100, heightCount: 100)
////
////    }
//}

class PineGenerator {
    var pines = [Pine]()
    var fails: Int = 0
    init(NumberOfPines: Int, NoiseMap: GKNoiseMap, Width: CGFloat, Height: CGFloat, widthCount: Int, heightCount: Int) {
        let getDistance: ((Int, Int), SCNVector3) -> CGFloat = {
            let xDistance = $1.x - CGFloat($0.0)/CGFloat(widthCount)*Width
            let yDistance = $1.y - CGFloat($0.1)/CGFloat(heightCount)*Height
            return pow(pow(xDistance,0.5)+pow(yDistance,0.5), 2)
        }
        var iterant: Int = 0
        while (pines.count < NumberOfPines) && (fails <= 100) {
//            print(iterant)
            iterant += 1
            let attempt = (Int.random(in: 0..<widthCount),Int.random(in: 0..<heightCount))
            if NoiseMap.interpolatedValue(at: vector_float2(Float(attempt.0),Float(attempt.1))) <= -1 && pines.map({getDistance(attempt,$0.position)}).contains(where: {$0<=2}) == false{
                    pines.append(Pine(Position: SCNVector3(x: CGFloat(attempt.0)/CGFloat(widthCount)*Width, y: 0, z: CGFloat(attempt.1)/CGFloat(heightCount)*Height)))
            }else {
                fails += 1
            }
            
        }
        for pine in pines {
            pine.node.worldPosition = pine.position - SCNVector3(Width/2,-2,Height/2)
        }
    }
    
}

class Pine {
    
    var position: SCNVector3
    var node: SCNNode
    init(Position: SCNVector3) {
        self.position = Position
        let createSprite: SCNNode = {
            let virtualObjectScene: SCNScene = {
//                if Int.random(in: 0...1) == 0 {
                    return SCNScene(named: "art.scnassets/polyTree.scn")!
//                }else {
//                    return SCNScene(named: "art.scnassets/pine.scn")!
//                }
                
            }()
            
            let wrapperNode = SCNNode()
            
            for child in virtualObjectScene.rootNode.childNodes {
                child.geometry?.firstMaterial?.lightingModel = .physicallyBased
                child.movabilityHint = .movable
                wrapperNode.addChildNode(child)
                }
                return wrapperNode
        }()
        self.node = createSprite
        self.node.eulerAngles = SCNVector3(CGFloat.random(in: -0.2...0.2), CGFloat.random(in: 0...CGFloat.pi*2), CGFloat.random(in: -0.2...0.2))
    }
    
}

class Ground: Mesh {
    var noiseMap: GKNoiseMap
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int) {
        var vertices = [SCNVector3]()
        
        noiseMap = {
            let source = GKPerlinNoiseSource()
            source.persistence = 0.9
//            source.seed = Int32.random(in: 0...100)

            let noise = GKNoise(source)
            let size = vector2(1.0, 1.0)
            let origin = vector2(0.0, 0.0)
            let sampleCount = vector2(Int32(widthCount), Int32(heightCount))
            return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
        }()
//            Verticies.append(SCNVector3(x: CGFloat(w)/CGFloat(widthCount)*Width, y: CGFloat(noiseMap.interpolatedValue(at: vector_float2(Float(w),Float(h)))), z: CGFloat(h)/CGFloat(heightCount)*Height))
            
        
        
        for w in 0..<widthCount {
            for h in 0..<heightCount {
                let vertex = SCNVector3(x: width*CGFloat(w)/CGFloat(widthCount-1)-width/2, y: 1-CGFloat(noiseMap.interpolatedValue(at: vector_float2(Float(w),Float(h)))), z: height*CGFloat(h)/CGFloat(heightCount-1)-height/2)
                vertices.append(vertex)
            }
        }

        var indices = [UInt16]()

        let index: (Int,Int) -> Int = {return $0 * heightCount + $1}


        for w in 0..<widthCount-1 {
            for h in 0..<heightCount-1 {
                var squareVerticies = [UInt16]()
                squareVerticies.append(UInt16(index(w,h)))
                squareVerticies.append(UInt16(index(w,h+1)))
                squareVerticies.append(UInt16(index(w+1,h)))
                squareVerticies.append(UInt16(index(w+1,h+1)))

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[1])
                indices.append(squareVerticies[3])

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[3])
                indices.append(squareVerticies[2])
//
//                indices.append(squareVerticies[0])
//                indices.append(squareVerticies[3])
//                indices.append(squareVerticies[1])
//
//                indices.append(squareVerticies[0])
//                indices.append(squareVerticies[2])
//                indices.append(squareVerticies[3])
            }
        }
        
        super.init(Verticies: vertices, Indices: indices)
        self.node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNGeometry(sources: [source()], elements: [element()]), options: [:]))
        let color1: NSColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        let color2: NSColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
        self.node.geometry?.materials.first?.roughness.contents = 1
        self.node.geometry?.materials.first!.shaderModifiers = [.geometry :
            getShader(from: "groundShader")
        ]
    }
    
}


class SurfaceWaterMesh: Mesh {
    var initialVertices: [SCNVector3]!
    var Time: CGFloat = 0
    
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int) {
        var vertices = [SCNVector3]()
        for w in 0..<widthCount {
            for h in 0..<heightCount {
                let heightMap: CGFloat = 0
                let vertex = SCNVector3(x: width*CGFloat(w)/CGFloat(widthCount-1)-width/2, y: CGFloat(heightMap), z: height*CGFloat(h)/CGFloat(heightCount-1)-height/2)
                vertices.append(vertex)
            }
        }

        var indices = [UInt16]()

        let index: (Int,Int) -> Int = {return $0 * heightCount + $1}


        for w in 0..<widthCount-1 {
            for h in 0..<heightCount-1 {
                var squareVerticies = [UInt16]()
                squareVerticies.append(UInt16(index(w,h)))
                squareVerticies.append(UInt16(index(w,h+1)))
                squareVerticies.append(UInt16(index(w+1,h)))
                squareVerticies.append(UInt16(index(w+1,h+1)))

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[1])
                indices.append(squareVerticies[3])

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[3])
                indices.append(squareVerticies[2])
//
//                indices.append(squareVerticies[0])
//                indices.append(squareVerticies[3])
//                indices.append(squareVerticies[1])
//
//                indices.append(squareVerticies[0])
//                indices.append(squareVerticies[2])
//                indices.append(squareVerticies[3])
            }
        }
        
        super.init(Verticies: vertices, Indices: indices)
        self.initialVertices = self.Verticies
        let color: NSColor = #colorLiteral(red: 0, green: 0.9859127402, blue: 1, alpha: 0.5554098887)
        self.node.geometry?.materials.first!.diffuse.contents = color
        self.node.geometry?.materials.first?.metalness.contents = 1
        self.node.geometry?.materials.first?.roughness.contents = 0
        self.node.geometry?.materials.first?.multiply.contents = NSColor.white
        self.node.geometry?.materials.first?.shininess = 1
        self.node.geometry?.materials.first?.specular.contents = 1
        self.node.geometry?.materials.first!.shaderModifiers = [.geometry :
            getShader(from: "waterShader")
        ]
        
    }
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int, NoiseMap: GKNoiseMap, Threshold: CGFloat, NoiseMapWidth: Int, NoiseMapHeight: Int) {
        var vertices = [SCNVector3]()

        var indices = [UInt16]()
        let nHWWP: Int = NoiseMapWidth/widthCount //numberOfHeightsWithinWaterPoint
        let index: (Int, Int) -> Int = {return $1*widthCount+$0}
        for w in 0..<widthCount-1 {
            for h in 0..<heightCount-1 {
                var averageHeight: Float = 0
                let w2 = w * nHWWP
                let h2 = h * nHWWP
                for i in 0..<nHWWP {
                    for j in 0..<nHWWP {
                        averageHeight += NoiseMap.interpolatedValue(at: vector_float2(Float(w2+i),Float(h2+j)))
                    }
                }
                if CGFloat(averageHeight) < Threshold*CGFloat(nHWWP*nHWWP) {
                    print("F")
                    var squareVerticies = [UInt16]()
                    
                    vertices.append(SCNVector3(x: CGFloat(w)/CGFloat(widthCount)*width, y: 1, z: CGFloat(h)/CGFloat(heightCount)*height))
                    vertices.append(SCNVector3(x: CGFloat(w)/CGFloat(widthCount)*width, y: 1, z: CGFloat(h+1)/CGFloat(heightCount)*height))
                    vertices.append(SCNVector3(x: CGFloat(w+1)/CGFloat(widthCount)*width, y: 1, z: CGFloat(h)/CGFloat(heightCount)*height))
                    vertices.append(SCNVector3(x: CGFloat(w+1)/CGFloat(widthCount)*width, y: 1, z: CGFloat(h+1)/CGFloat(heightCount)*height))
                    
                    
                    squareVerticies.append(UInt16(indices.count))
                    squareVerticies.append(UInt16(indices.count))
                    squareVerticies.append(UInt16(indices.count))
                    squareVerticies.append(UInt16(indices.count))
                    
                    indices.append(squareVerticies[0])
                    indices.append(squareVerticies[1])
                    indices.append(squareVerticies[3])
    
                    indices.append(squareVerticies[0])
                    indices.append(squareVerticies[3])
                    indices.append(squareVerticies[2])
                    
                }
//
//                indices.append(squareVerticies[0])
//                indices.append(squareVerticies[1])
//                indices.append(squareVerticies[3])
//
//                indices.append(squareVerticies[0])
//                indices.append(squareVerticies[3])
//                indices.append(squareVerticies[2])

                
            }
        }
        
        super.init(Verticies: vertices, Indices: indices)
        self.initialVertices = self.Verticies
        let color: NSColor = #colorLiteral(red: 0, green: 0.9859127402, blue: 1, alpha: 0.5554098887)
        self.node.geometry?.materials.first!.diffuse.contents = color
        self.node.geometry?.materials.first?.metalness.contents = 1
        self.node.geometry?.materials.first?.roughness.contents = 0
        self.node.geometry?.materials.first?.multiply.contents = NSColor.white
        self.node.geometry?.materials.first?.shininess = 1
        self.node.geometry?.materials.first?.specular.contents = 1
        self.node.geometry?.materials.first!.shaderModifiers = [.geometry :
            getShader(from: "waterShader")
        ]
            
    }
}

private func getShader(from filename: String) -> String {
    do {
        if let dirs = Bundle.main.url(forResource: filename, withExtension: "shader") {
            return try String(contentsOf: dirs, encoding: .utf8)
        }
    } catch {
        print(error)
    }
    print("shader \(filename) not found")
    return ""
}


