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
    init(NumberOfPines: Int, Points: inout [SCNVector3]) {
        let getDistance: (SCNVector3, SCNVector3) -> CGFloat = {
            let xDistance = $1.x - $0.x
            let zDistance = $1.z - $0.z
            return pow(pow(xDistance,2)+pow(zDistance,2), 0.5)
        }
        var iterant: Int = 0
        var points = Points
        points.removeAll(where: {$0.y < 2})
        while (trees.count < NumberOfPines) && (fails <= 100) && (trees.count < points.count/100) {
            iterant += 1
            let attempt = points.randomElement()!
            if trees.map({getDistance(attempt,$0.position)}).contains(where: {$0<=2}) == false{
                    trees.append(Acacia(Position: attempt))
//                print(Points.firstIndex(where: {$0.vector == attempt})!, Points[Points.firstIndex(where: {$0.vector == attempt})!].vector, attempt)
//                Points[Points.firstIndex(where: {$0.vector == attempt})!].status = .Tree
             }else {fails += 1}
            
        }
        if trees.count < NumberOfPines {
            print("Tree Failed Out")
        }
        for tree in trees {
            tree.node.worldPosition = tree.position
//            tree.position = tree.position - SCNVector3(Width/2,-2,Height/2)
//            tree.node.worldPosition = tree.position
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
