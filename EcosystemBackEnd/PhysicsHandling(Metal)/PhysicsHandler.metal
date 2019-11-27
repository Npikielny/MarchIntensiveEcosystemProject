//
//  PhysicsHandler.metal
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/26/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct physicsBody {
    float3 position;
    float3 velocity;
    float heightOfMap;
    float direction;
    int id;
};

float3 setY(float3 vector, float yComponent)
{
    return float3(vector.x,yComponent,vector.y);
}

kernel void calculatePhysics(device physicsBody *buffer,
                        uint index [[thread_position_in_grid]])
{
    if (buffer[index].position.y > buffer[index].heightOfMap) {
//        buffer[index].velocity.y -= 9.80665;
        buffer[index].position = setY(buffer[index].position,0);
    }
//    buffer[index].position += buffer[index].velocity;
}
