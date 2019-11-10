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
        }
        print(ground.pineGen.pines.count)
        
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
        water = SurfaceWaterMesh(width: 400, height: 400, widthCount: 50, heightCount: 50)
        water.INIT_TIMER()
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
        
        let color: NSColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        self.node.geometry?.materials.first?.diffuse.contents = color
    }
    
}
//class Ground {
//    var Verticies = [SCNVector3]()
//    var Indices = [UInt16]()
//
//    var node: SCNNode!
//
//    func source() -> SCNGeometrySource {return SCNGeometrySource(vertices: self.Verticies)}
//    func element() -> SCNGeometryElement {return SCNGeometryElement(indices: self.Indices, primitiveType: SCNGeometryPrimitiveType.triangles)}
//
//
//
//    init(Width: CGFloat, widthCount: Int32, Height: CGFloat, heightCount: Int32) {
//        let noiseMap: GKNoiseMap = {
//            let source = GKPerlinNoiseSource()
//            source.persistence = 0.9
//
//            let noise = GKNoise(source)
//            let size = vector2(1.0, 1.0)
//            let origin = vector2(0.0, 0.0)
//            let sampleCount = vector2(widthCount, heightCount)
//            return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
//        }()
//        for i in 0..<widthCount*heightCount {
//            let h = i/widthCount
//            let w = i - h
////            Verticies.append(SCNVector3(x: CGFloat(w)/CGFloat(widthCount)*Width, y: CGFloat(noiseMap.interpolatedValue(at: vector_float2(Float(w),Float(h)))), z: CGFloat(h)/CGFloat(heightCount)*Height))
//            Verticies.append(SCNVector3(x: CGFloat(w)/CGFloat(widthCount)*Width, y: 0, z: CGFloat(h)/CGFloat(heightCount)*Height))
//        }
//
//
//        let index: (Int32,Int32) -> Int32 = {return $0 * heightCount + $1}
//
//
//        for w in 0..<widthCount-1 {
//            for h in 0..<heightCount-1 {
//                var squareVerticies = [UInt16]()
//                squareVerticies.append(UInt16(index(w,h)))
//                squareVerticies.append(UInt16(index(w,h+1)))
//                squareVerticies.append(UInt16(index(w+1,h)))
//                squareVerticies.append(UInt16(index(w+1,h+1)))
//
//                Indices.append(squareVerticies[0])
//                Indices.append(squareVerticies[1])
//                Indices.append(squareVerticies[3])
//
//                Indices.append(squareVerticies[0])
//                Indices.append(squareVerticies[3])
//                Indices.append(squareVerticies[2])
//
//                Indices.append(squareVerticies[0])
//                Indices.append(squareVerticies[3])
//                Indices.append(squareVerticies[1])
//
//                Indices.append(squareVerticies[0])
//                Indices.append(squareVerticies[2])
//                Indices.append(squareVerticies[3])
//            }
//        }
//
//        node = SCNNode(geometry: SCNGeometry(sources: [source()], elements: [element()]))
//
//
//
//    }
//
//
//
//}



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
        self.node.geometry?.materials.first?.diffuse.contents = color
    }
    
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int, NoiseMap: GKNoiseMap) {
        var vertices = [SCNVector3]()
        for w in 0..<widthCount {
            for h in 0..<heightCount {
                let heightMap: CGFloat = 0
                if NoiseMap.interpolatedValue(at: vector_float2(Float(w),Float(h))) < 2 {
                    let vertex = SCNVector3(x: width*CGFloat(w)/CGFloat(widthCount-1)-width/2, y: CGFloat(heightMap), z: height*CGFloat(h)/CGFloat(heightCount-1)-height/2)
                    vertices.append(vertex)
                }
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
        self.node.geometry?.materials.first?.diffuse.contents = color
    }
    
    
    
    @objc func step() {
        self.Time += CGFloat.pi/30/4
        for index in 0..<self.initialVertices.count {
            let pp = self.Verticies[index].y*0.1
//            let amp = (200-self.initialVertices[index].x)/200
            let amp: CGFloat = 1
            let shoreDistanceTransfer: CGFloat = (200+(self.initialVertices[index].x))/200
            let positionTransfer: CGFloat = (self.initialVertices[index].x/10)-cos(self.initialVertices[index].z/10)-pp
            let yComp: CGFloat = sin(Time-positionTransfer)*amp/2+1.5
            self.Verticies[index] = self.initialVertices[index]+SCNVector3(x: 0, y: yComp, z: 0)
        }
        self.makeMesh()
    }
    
    override func customizeMesh() {
        let color: NSColor = #colorLiteral(red: 0, green: 0.9859127402, blue: 1, alpha: 0.5554098887)
        self.node.geometry?.materials.first?.diffuse.contents = color
    }
    
    func INIT_TIMER() {
        _ = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(step), userInfo: nil, repeats: true)
    }
    
}


extension SCNVector3 {
    func getMagnitude() -> CGFloat {
        return pow(pow(self.x,2)+pow(self.y,2)+pow(self.z,2), 0.5)
        
    }
    
    func scalarMultiplication(Scalar: CGFloat) -> SCNVector3 {
        let Vector = self
        return SCNVector3(x: Vector.x*Scalar, y: Vector.y*Scalar, z: Vector.z*Scalar)
    }
    
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    static func += (left: inout SCNVector3, right: SCNVector3) {
        left = SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func -= (left: inout SCNVector3, right: SCNVector3) {
        left = SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func * (left: inout SCNVector3, right: CGFloat) {
        left = SCNVector3(left.x * right, left.y * right, left.z * right)
    }
    
    static func == (left: SCNVector3, right: SCNVector3) -> Bool {
        if (left.x==right.x&&left.y==right.y&&left.z==left.z) {return true}else{return false}
    }
    
    static func != (left: SCNVector3, right: SCNVector3) -> Bool {
        return !(left == right)
    }
    
    func translatedDirectionVector(Center: SCNVector3) -> SCNVector3 {
        return directionVector(Center: Center) + Center
    }
    
    func directionVector(Center: SCNVector3) -> SCNVector3 {
        return (self - Center).unitVector()
    }
    
    func unitVector() -> SCNVector3 {
        let magnitude = pow(pow(self.x, 2)+pow(self.y, 2)+pow(self.z, 2), 0.5)
        if magnitude > 0 {
            return self.scalarMultiplication(Scalar: 1/magnitude)
        }else {
            return SCNVector3().zero()
        }
    }
    
    func toMagnitude(_ Magnitude: CGFloat) -> SCNVector3 {
        return self.unitVector().scalarMultiplication(Scalar: Magnitude)
    }
    
    func zero() -> SCNVector3 {
        return SCNVector3(x: 0, y: 0, z: 0)
    }
    
    func clamp(Min: CGFloat, Max: CGFloat) -> SCNVector3 {
        if self.getMagnitude() < Min {
            return self.toMagnitude(Min)
        }else if self.getMagnitude() > Max {
            return self.toMagnitude(Max)
        }else {
            return self
        }
    }
    
    func clampMagnitudeComponent(ComponentMinMax: [component:(CGFloat,CGFloat)]) {
        var finalVector = self
        let clampComponent: (CGFloat, CGFloat, CGFloat) -> CGFloat = {if abs($0) > $1 && abs($0) < $2 {return $0}else if abs($0) < $1 {return $1}else {return $2}}
        
        for i in ComponentMinMax {
            if i.key == .y {
                finalVector = finalVector.setValue(Component: .y, Value: clampComponent(finalVector.y,i.value.0,i.value.1))
            }else if i.key == .x {
                finalVector = finalVector.setValue(Component: .x, Value: clampComponent(finalVector.x,i.value.0,i.value.1))
            }else if i.key == .z {
                finalVector = finalVector.setValue(Component: .z, Value: clampComponent(finalVector.z,i.value.0,i.value.1))
            }
        }
    }
    
    func clampComponent(ComponentMinMax: [component:(CGFloat,CGFloat)]) -> SCNVector3 {
        var finalVector = self
        let clampComponent: (CGFloat, CGFloat, CGFloat) -> CGFloat = {if ($0) > $1 && ($0) < $2 {return $0}else if ($0) < $1 {return $1}else {return $2}}
        
        for i in ComponentMinMax {
            if i.key == .y {
                finalVector = finalVector.setValue(Component: .y, Value: clampComponent(finalVector.y,i.value.0,i.value.1))
            }else if i.key == .x {
                finalVector = finalVector.setValue(Component: .x, Value: clampComponent(finalVector.x,i.value.0,i.value.1))
            }else if i.key == .z {
                finalVector = finalVector.setValue(Component: .z, Value: clampComponent(finalVector.z,i.value.0,i.value.1))
            }
        }
        return finalVector
    }
    
    func setValue(Component: component, Value: CGFloat) -> SCNVector3 {
        if Component == .x {
            return SCNVector3(Value,self.y,self.z)
        }else if Component == .y {
            return SCNVector3(self.x,Value,self.z)
//        }else if Component == .z {
//            return SCNVector3(self.x,self.y,Value)
        }
        else {
                return SCNVector3(self.x,self.y,Value)
            }
    }
    
    func random() -> SCNVector3 {
        let vector = SCNVector3(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5), z: CGFloat.random(in: -5...5)).unitVector()
        if vector.getMagnitude() == 0 {
            return random()
        }else {
            return vector
        }
    }
    
    func zero(_ Component: component...) -> SCNVector3 {
        var vector = self
        for i in Component {
            if i == .x {
                vector = SCNVector3(x: 0, y: vector.y, z: vector.z)
            }else if i == .y {
                vector = SCNVector3(x: vector.x, y: 0, z: vector.z)
            }else if i == .z {
                vector = SCNVector3(x: vector.x, y: vector.y, z: 0)
            }
        }
        return vector
    }
}

enum component {
    case x
    case y
    case z
}

