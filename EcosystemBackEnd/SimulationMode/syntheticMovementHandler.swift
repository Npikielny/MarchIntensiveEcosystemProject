//
//  syntheticMovementHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 1/4/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import SceneKit

extension SimulationHandler {
    func syntheticMovementHandler(item: inout Animal) {
        if item.dead == false && item.node.worldPosition.y <= 0 {
            if isNearTarget(item: &item) { // logic for setting new target
                item.node.worldPosition = item.target

                switch item.priority {
                case .Water:
                    item.drink()
                    if item.thirst >= 100 {
                        item.checkPriority()
                        setTarget(item: &item)
                    }
                case .Food:
                    if let _ = item.targetFood {
                       if item.eat(Item: &item.targetFood!) {
                           item.targetFood = nil
                           item.checkPriority()
                        setTarget(item: &item)
                       }
                   } else {
                        setTarget(item: &item)
                   }
                case .Breed:
                    let success: Bool = {
                        if let node = item.targetMate?.targetMate?.node {
                            if node == item.node {
                                item.breed()
                                return true
                            }
                        }
                        return false
                    }()
                    item.inProcess = true
                    if success == false {
                        item.inProcess = false
                        item.checkPriority()
                        setTarget(item: &item)
                    }
                    if item.breedingUrge >= 100 {
                        item.inProcess = false
                        item.checkPriority()
                        setTarget(item: &item)
                    }
                default:
                    item.checkPriority()
                    setTarget(item: &item)
                }
            }else {
                move(item: &item)
            }
//            additionalPhysics() // overridable function
//            look() // handles looking
//            handleStats()
            item.Speed = CGFloat(3/(1 + pow(2.18,0.1*(item.age-15))))
            if (item.node.worldPosition.zero(.y) - item.target.zero(.y)).getMagnitude() <= 0.5 {
                item.node.worldPosition = item.target.setValue(Component: .y, Value: 2-item.node.boundingBox.min.y+0.1)
                item.velocity = SCNVector3().zero()
            }
        }
    }
    
    func setTarget(item: inout Animal) {
        switch item.priority {
            
            case .Food:
                if let _ = item.targetFood {}else {
                    var nearbyFoods = item.handler.foods
                    nearbyFoods.sort(by: {($0.node.worldPosition - item.node.worldPosition).getMagnitude()<($1.node.worldPosition - item.node.worldPosition).getMagnitude()})
                    if nearbyFoods.count > 0 {
                        item.targetFood = nearbyFoods.first
                        item.target = item.targetFood!.node.worldPosition
                    } else {
                        randomTarget(item: &item)
                    }
                }

            case .Water:
                var groundVerts = item.handler.drinkableVertices!
                groundVerts.sort(by: {($0.vector - item.node.position).getMagnitude()<($1.vector - item.node.position).getMagnitude()})
                if let position = groundVerts.first {
                    item.target = position.vector
                }else {
                    item.checkPriority()
                    randomTarget(item: &item)
                }

            case .Breed:
                if let _ = item.targetMate {
                    item.targetMate = nil
                    item.checkPriority()
                } else {
                    var breedingTargets = item.handler.animals
                    breedingTargets.removeAll(where: {$0.node.worldPosition == item.node.worldPosition})
                    breedingTargets.removeAll(where: {$0.sex == item.sex})
                    breedingTargets.sort(by: {($0.node.worldPosition - item.node.worldPosition).getMagnitude()<($1.node.worldPosition - item.node.worldPosition).getMagnitude()})

                    for index in 0..<breedingTargets.count {
                        if let _ = item.targetMate{} else {
                            if let _ = breedingTargets[index].targetMate {} else {
                                breedingTargets[index].breedRequest(item)
                            }
                        }
                    }

                    if let _ = item.targetMate {} else {
                        item.checkPriority()
                        randomTarget(item: &item)
                    }
                }

                if let _ = item.targetMate {
                    if ((item.targetMate?.node.worldPosition)! - item.node.worldPosition).getMagnitude() < 0.5 {
                        item.inProcess = true
                        item.targetMate?.inProcess = true
                    }else {item.target = (item.targetMate!.node.worldPosition + item.node.worldPosition).scalarMultiplication(Scalar: 0.5)}
                }else {
                    item.checkPriority()
                    randomTarget(item: &item)
                }

            case .Flee:
                randomTarget(item: &item)

            default: //Idle
                randomTarget(item: &item)
        }
    }
    

    func randomTarget(item: inout Animal) {
        item.target = (coordinateTransfer(item.node.worldPosition + SCNVector3().random().toMagnitude(20)))
        item.target = item.target.setValue(Component: .y, Value: item.handler.mapValueAt(item.target))
    }

    func coordinateTransfer(_ Vector: SCNVector3) -> SCNVector3 {
        let transfer: (CGFloat) -> (CGFloat) = {return CGFloat(Int($0/4)*4)}
        return SCNVector3(x: transfer(Vector.x), y: transfer(Vector.y), z: transfer(Vector.z))
    } // Finds a nearby point on the map

    func isNearTarget(item: inout Animal) -> Bool {
        return ((item.target - item.node.worldPosition).zero(.y).getMagnitude() <= item.Speed/3)
    }
    
    func move(item: inout Animal) {
        let distance = (item.target - item.node.worldPosition).zero(.y).getMagnitude()
        if distance <= item.Speed {
            let velocity = pow(abs(1)*distance,0.5)
            item.velocity = (item.target - item.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
        }else {
            let velocity = pow(abs(1)*item.Speed,0.5)
            item.velocity = (item.target - item.node.worldPosition).zero(.y).toMagnitude(velocity).setValue(Component: .y, Value: velocity)
        }
    }
    
}
