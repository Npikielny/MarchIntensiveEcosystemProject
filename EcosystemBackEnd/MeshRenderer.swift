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
        water = SurfaceWaterMesh(width: 400, height: 400, widthCount: 25, heightCount: 25)
        water.node.name = "Water"
        pineGen = PineGenerator(NumberOfPines: 500, NoiseMap: ground.noiseMap, Width: 400, Height: 400, widthCount: 100, heightCount: 100)
    }
    
}

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
            pine.node.worldPosition = pine.position - SCNVector3(Width/2,-1.5,Height/2)
        }
    }
    
}

class Pine {
    
    var position: SCNVector3
    var node: SCNNode
    init(Position: SCNVector3) {
        self.position = Position
        let createSprite: SCNNode = {
            let virtualObjectScene = SCNScene(named: "art.scnassets/pine.scn")!
            
            let wrapperNode = SCNNode()
            
            for child in virtualObjectScene.rootNode.childNodes {
                child.geometry?.firstMaterial?.lightingModel = .physicallyBased
                child.movabilityHint = .movable
                wrapperNode.addChildNode(child)
                }
                return wrapperNode
        }()
        self.node = createSprite
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
                let heightMap: CGFloat = 0
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

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[3])
                indices.append(squareVerticies[1])

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[2])
                indices.append(squareVerticies[3])
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

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[3])
                indices.append(squareVerticies[1])

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[2])
                indices.append(squareVerticies[3])
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


