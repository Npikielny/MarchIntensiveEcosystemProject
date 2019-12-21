//
//  PhysicsHandler.metal
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/26/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct animal {
    float3 position;
    float3 target;
    float age;
    float maxSpeed;
    float hunger;
    float thirst;
    float health;
    float breedingUrge;
    bool waiting;
    int id;
};

float3 dsitance(float3 vector1, float3 vector2)
{
    return pow((vector1.x-vector2.x)*(vector1.x-vector2.x) + (vector1.y-vector2.y)*(vector1.y-vector2.y) + (vector1.z-vector2.z)*(vector1.z-vector2.z),0.5);
}

kernel void calculatePhysics(device animal *buffer,
                        uint index [[thread_position_in_grid]])
{
    if (buffer[index].waiting == false) {
        buffer[index].position = buffer[index].target;
    }
}
