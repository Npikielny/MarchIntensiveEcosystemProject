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
    float3 velocity;    
    float3 target;      
    float age;          
    float hunger;       
    float thirst;       
    float health;       
    float breedingUrge; 
    int id; 
};


kernel void calculatePhysics(device animal *buffer,
                        uint index [[thread_position_in_grid]])
{
    buffer[index].age += 0.001;
    if (buffer[index].age > 6) {

    }
    float maxSpeed = pow(2.18,0.1*(buffer[index].age-15));
    float ageMultiplier = 1 + pow(2.18,-0.3*(buffer[index].age-6));
    if (buffer[index].hunger > 0) {
        buffer[index].hunger = (buffer[index].hunger-(distance(float3(0,0,0), buffer[index].velocity) * (ageMultiplier) * 0.0018*2));
    }else {
        buffer[index].hunger = 0;
        buffer[index].health -= ageMultiplier * 0.025 * buffer[index].age/6;
    }
    if (buffer[index].thirst > 0) {
            buffer[index].thirst = buffer[index].thirst-(distance(float3(0,0,0), buffer[index].velocity) * (ageMultiplier) * 0.0027*2);
            buffer[index].thirst -= 0.0001;
    }else {
        buffer[index].thirst = 0;
        buffer[index].health -= ageMultiplier * 0.025 * buffer[index].age/6;
    }
    if (buffer[index].breedingUrge > 0) {
        if ((buffer[index].age >= 6) && (buffer[index].age <= 18)) {
            if ((buffer[index].hunger > 40) && (buffer[index].thirst > 40)) {
                buffer[index].breedingUrge -= 0.055;
            }
        }else {
            buffer[index].breedingUrge = 100;
        }
    }else {
        buffer[index].breedingUrge = 0;
    }

    float difference = 0.1;
    if (buffer[index].position.y > 0) {
        buffer[index].velocity.y += -9.807*difference;

    }
    buffer[index].position += buffer[index].velocity*difference;
    if (buffer[index].position.y <= 0) {
        buffer[index].velocity = float3(0,0,0);
        buffer[index].position.y = 0;
        if (distance(buffer[index].position, buffer[index].target) < maxSpeed/3) {
            buffer[index].position = buffer[index].target;
        }else {
            buffer[index].position = float3(buffer[index].position.x,0,buffer[index].position.z);
        }
    }
    
}
