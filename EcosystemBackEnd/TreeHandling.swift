//
//  TreeHandling.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/12/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import GameplayKit
import SceneKit

class TreeGenerator {
    var trees = [Tree]()
    var fails: Int = 0
    init(NumberOfPines: Int, NoiseMap: GKNoiseMap, Width: CGFloat, Height: CGFloat, widthCount: Int, heightCount: Int) {
        let getDistance: ((Int, Int), SCNVector3) -> CGFloat = {
            let xDistance = $1.x - CGFloat($0.0)/CGFloat(widthCount)*Width
            let yDistance = $1.y - CGFloat($0.1)/CGFloat(heightCount)*Height
            return pow(pow(xDistance,0.5)+pow(yDistance,0.5), 2)
        }
        var iterant: Int = 0
        while (trees.count < NumberOfPines) && (fails <= 100) {
            iterant += 1
            let attempt = (Int.random(in: 0..<widthCount),Int.random(in: 0..<heightCount))
            if NoiseMap.interpolatedValue(at: vector_float2(Float(attempt.0),Float(attempt.1))) <= -1 && trees.map({getDistance(attempt,$0.position)}).contains(where: {$0<=2}) == false{
                    trees.append(Acacia(Position: SCNVector3(x: CGFloat(attempt.0)/CGFloat(widthCount)*Width, y: 0, z: CGFloat(attempt.1)/CGFloat(heightCount)*Height)))
            }else {
                fails += 1
            }
            
        }
        for tree in trees {
            tree.position = tree.position - SCNVector3(Width/2,-2,Height/2)
            tree.node.worldPosition = tree.position
        }
    }
    
}

class Tree {
    var position: SCNVector3
    var node: SCNNode
    init(Position: SCNVector3, Species: String) {
        self.position = Position
        self.node = getPrefab(Species + ".scn", Shaders: "genericShader")
        self.node.name = Species
        naturalizeTree()
    }
    
    func apple(Handler: EnvironmentHandler) {
        if Int.random(in: 0...50000) == 1 {
            let apple = Apple(Position: self.position+SCNVector3().random().toMagnitude(1).zero(.y)+self.node.boundingBox.max.scalarMultiplication(Scalar: CGFloat.random(in: 0.7...0.9)).zero(.x,.z), Handler: Handler)
            Handler.Scene.rootNode.addChildNode(apple.node)
            apple.node.geometry?.shaderModifiers = [.geometry:getShader(from: "tree")]
        }
        
    }
    
    func naturalizeTree() {
        self.node.eulerAngles = SCNVector3(CGFloat.random(in: -0.2...0.2), CGFloat.random(in: 0...CGFloat.pi*2), CGFloat.random(in: -0.2...0.2))
        self.node.scale = SCNVector3(1, 1, 1).scalarMultiplication(Scalar: CGFloat.random(in: 0.5...1.5))
    }
    
}

class Acacia: Tree {
    
    init(Position: SCNVector3) {
        super.init(Position: Position, Species: "acacia")
    }
    
}

class Pine: Tree {
    
    init(Position: SCNVector3) {
        super.init(Position: Position, Species: "pine")
    }
    
    override func naturalizeTree() {
        self.node.scale = SCNVector3(1, 1, 1).scalarMultiplication(Scalar: CGFloat.random(in: 0.5...1.5))
    }
    
}
