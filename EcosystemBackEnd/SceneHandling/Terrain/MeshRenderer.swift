//
//  MeshRenderer.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/10/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit
import GameplayKit


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

struct SpaciallyAwareVector {
    var vector: SCNVector3
    var status: pointTypes
}

enum pointTypes {
    case Tree
    case NearWater
    case Normal
    case Water
}

class Ground: Mesh {
    var verts = [SCNVector3]()
    var vertices = [SpaciallyAwareVector]()
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int, Gen: generator) {
        for z in 0..<widthCount {
            for x in 0..<heightCount {
//                print(gen.valueFor(x: Int32(x), y: Int32(z))/255+0.5)
//                verts.append(SCNVector3(x: CGFloat(x)/CGFloat(widthCount)*width-width/2, y: CGFloat.random(in: 0...6), z: CGFloat(z)/CGFloat(heightCount)*height-height/2))
                let Height: CGFloat = CGFloat(Gen.valueFor(x: Int32(x), y: Int32(z)))
                verts.append(SCNVector3(x: CGFloat(x)/CGFloat(widthCount)*width-width/2, y: Height, z: CGFloat(z)/CGFloat(heightCount)*height-height/2))
            }
        }

        let determinant: (SCNVector3) -> pointTypes = {
            if $0.y >= 1.6 {
                return .Normal
            }else {
                return .Water
            }
        }
        vertices = verts.map({SpaciallyAwareVector(vector: $0, status: determinant($0))})
//        vertices = verts.map({SpaciallyAwareVector(vector: $0, status: .Normal)})
        
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
                var found: Bool = false
                for i in squareVerticies {
                    if self.vertices[Int(i)].vector.y < 1.6 {
                        found = true
                    }
                }
                if found == true {
                    for i in squareVerticies {
                        if self.vertices[Int(i)].vector.y >= 1.6 {
                            self.vertices[Int(i)].status = .NearWater
                        }
                    }
                }
            }
        }

        super.init(Verticies: verts, Indices: indices)
//        self.node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNGeometry(sources: [source()], elements: [element()]), options: [:]))

    }

    override func customizeMesh() {
        let _: NSColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        let _: NSColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
        let _: NSColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        
        self.node.geometry?.materials.first?.roughness.contents = 1
        self.node.geometry?.materials.first!.setValue(Float(0), forKey: "x")
        self.node.geometry?.materials.first!.setValue(Float(0), forKey: "z")
        self.node.geometry?.materials.first!.shaderModifiers = [.geometry :
            getShader(from: "groundShader")
        ]
    }
}

struct heightMapValue {
    var position: SIMD3<Float>
    var storedPosition: SIMD3<Float>
    init(_ Vector: SCNVector3) {
        self.storedPosition = SIMD3(Vector)
        self.position = SIMD3(Vector.zero(.y))
    }
    
    init(_ Position: SCNVector3, _ StoredPosition: SCNVector3) {
        self.storedPosition = SIMD3(StoredPosition)
        self.position = SIMD3(Position)
    }
    static let size = MemoryLayout<heightMapValue>.stride
}

class SurfaceWaterMesh: Mesh {
    var Time: CGFloat = 0
    
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int) {
        var vertices = [SCNVector3]()
        for w in 0..<widthCount {
            for h in 0..<heightCount {
                let heightMap: CGFloat = 0
                let vertex = SCNVector3(x: width*CGFloat(w)/CGFloat(widthCount)-width/2, y: CGFloat(heightMap), z: height*CGFloat(h)/CGFloat(heightCount)-height/2)
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
        
    }
    
    init(GroundVertices: [SCNVector3], GroundIndices: [UInt16]) {
        let verts = GroundVertices.map({$0.setValue(Component: .y, Value: 0)})
        super.init(Verticies: verts, Indices: GroundIndices)
    }
    
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int, NoiseMap: GKNoiseMap, Threshold: CGFloat, NoiseMapWidth: Int, NoiseMapHeight: Int) {
        var vertices = [SCNVector3]()
        var indices = [UInt16]()
        
        var squares = [[SCNVector3]]()
        
        let conversion = NoiseMapWidth/widthCount
        for w in 0...widthCount {
            for h in 0...heightCount {
                var found: Int = 0
                for w2 in 0...conversion {
                    for h2 in 0...conversion {
                        if CGFloat(NoiseMap.interpolatedValue(at: vector_float2(Float(w*conversion+w2),Float(h*conversion+h2)))) > Threshold {
                            found += 1
                        }
                    }
                }
                if found > 0 {
                    squares.append([SCNVector3(CGFloat(w)/CGFloat(widthCount)*width,0,CGFloat(h)/CGFloat(heightCount)*height),
                                    SCNVector3(CGFloat(w)/CGFloat(widthCount)*width,0,CGFloat(h+1)/CGFloat(heightCount)*height),
                                    SCNVector3(CGFloat(w+1)/CGFloat(widthCount)*width,0,CGFloat(h)/CGFloat(heightCount)*height),
                                    SCNVector3(CGFloat(w+1)/CGFloat(widthCount)*width,0,CGFloat(h+1)/CGFloat(heightCount)*height)])
                }

            }
        }
        
        
        for i in squares {
            let initialCount = UInt16(vertices.count)
            for vertex in i {
                vertices.append(vertex)
            }
            indices.append(UInt16(0+initialCount))
            indices.append(UInt16(1+initialCount))
            indices.append(UInt16(3+initialCount))
            
            indices.append(UInt16(0+initialCount))
            indices.append(UInt16(3+initialCount))
            indices.append(UInt16(2+initialCount))
            
        }
        
        super.init(Verticies: vertices, Indices: indices)
    }
    
    override func customizeMesh() {
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
//        self.node.geometry?.materials = [material]
        
    }
}

func getShader(from filename: String) -> String {
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

extension SimulationBase {
    func mapValueAt (_ Vector: SCNVector3) -> (CGFloat) {
        let h = CGFloat(self.gen.valueFor(x: Int32((Vector.x + self.mapDimension / 2) / self.mapDimension * CGFloat(self.mapCountDimension)), y: Int32((Vector.z + self.mapDimension / 2) / self.mapDimension * CGFloat(self.mapCountDimension))))
        if h < 1.6 {
            return h - 2
        }else {
            return h
        }
        
    }
    
    func mapValueAt(_ X: CGFloat,_ Z: CGFloat) -> (CGFloat) {
        let h = CGFloat(self.gen.valueFor(x: Int32((X + self.mapDimension / 2) / self.mapDimension * CGFloat(self.mapCountDimension)), y: Int32((Z + self.mapDimension / 2) / self.mapDimension * CGFloat(self.mapCountDimension))))
        if h < 1.6 {
            return h - 2
        }else {
            return h
        }
        
    }
    
    
}



struct RGBA32 {
    var color: UInt32
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
    }
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
    
    static let size = MemoryLayout<RGBA32>.stride
    
    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }

    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }

    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }

    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    var colorComponents: (UInt8,UInt8,UInt8,UInt8) {
        return (self.redComponent,self.greenComponent,self.blueComponent,self.alphaComponent)
    }
    
}
