//
//  MeshRendering.metal
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 1/24/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct pixel {
    uint32_t color;
};


uint8_t redComponent (uint32_t color) {
    return ((color >> 24) & 255);
}

uint8_t greenComponent (uint32_t color) {
    return ((color >> 16) & 255);
}

uint8_t blueComponent (uint32_t color) {
    return ((color >> 8) & 255);
}

uint8_t alphaComponent(uint32_t color) {
    return ((color >> 0) & 255);
}

uint32_t createEntry(uint8_t red,
                 uint8_t green,
                 uint8_t blue,
                 uint8_t alpha) {
    return ((red) << 24) | ((green) << 16) | ((blue) << 8) | ((alpha) << 0);
}

constant int widthValue [[function_constant(0)]];
constant int heightValue [[function_constant(1)]];
constant int octaves [[function_constant(2)]];
constant int noiseX [[function_constant(3)]];
constant int noiseZ [[function_constant(4)]];
constant int noiseSeed [[function_constant(5)]];
constant int seed [[function_constant(6)]];
constant float p [[function_constant(7)]];
constant float zoom [[function_constant(8)]];


float getNoise(int Index) {
    float transform = 200;
    return 1.5 / abs(sin(float(Index)/transform)+cos(float(Index)/transform));
}


int overflowMultiplication (int x1, int x2) {
    int multiplication = x1 * x2;
    int overHang = int(pow(float(2), float(32)));
    int overflow = (multiplication + overHang / 2) / overHang;
    return multiplication - overflow * overHang;
}

half findNoise(half x, half z) {
    int n = noiseX * int(x) + noiseZ * int(z) + noiseSeed * seed;
    n = (n >> 13) ^ n;
    n = overflowMultiplication(n, overflowMultiplication(n, overflowMultiplication(n, (60493 + 19990303))) + 1376312589) & 0x7fffffff;
    return 1 - float (n) / 1073741824;
}


float interpolate(float a, float b, float x) {
    half ft = x * acos(half(0));
    half f = (1.0-cos(ft)) * 0.5;
    return float(a*(1.0-f)+b*f);
}


half noise(half x, half z) {

    half floorX = half(int(x));
    half floorZ = half(int(z));
    
    half s = findNoise(floorX, floorZ);
    half t = findNoise(floorX+1, floorZ);
    half u = findNoise(floorX, floorZ+1);
    half v = findNoise(floorX+1, floorZ+1);
    
    
    half i1 = interpolate(s, t, x-floorX);
    half i2 = interpolate(u, v, x-floorX);
    
    return interpolate(i1, i2, z-floorZ);
}

float valueFor(int x, int z) {
    half netNoise = 0;
    for (int index = 0; index < octaves; index ++) {
        half frequency = pow(2, half(index));
        half amplitude = pow(half(p), half(index));
        netNoise += noise(half(x)*frequency/half(zoom),half(z)*frequency/half(zoom))*amplitude;
    }
    float value = float(netNoise+1)*128;
    if (value > 255) {
        value = 255;
    }else if (value < 0) {
        value = 0;
    }
    return value;
}

kernel void createImage(device pixel *buffer,
                        uint index [[thread_position_in_grid]]) {
    
    
    int height = (index/widthValue) / 2 / 8; //determining Width
    int width = index % (widthValue) / 8;
    
//    int2 chunkMin = int2(int(width / 40)*40, int(height / 40)*40);
//    buffer[index].color = createEntry(float(chunkMin.x)/float(widthValue)*255, float(chunkMin.y)/float(heightValue)*255, 0, 255);
//    buffer[index].color = createEntry(float(chunkMin.x)/float(widthValue) * 255, float(chunkMin.y)/float(heightValue) * 255, 0, 255);
//    int zVal = getNoise(index) * 0.1;
//    float xPercent = (width - chunkMin.x) / 40;
//    zVal += getNoise(index - (width - chunkMin.x)) * 0.45 * xPercent;
//    zVal += getNoise(index - (width - chunkMin.x) + 40) * 0.45 * (1-xPercent);
//    float zVal = 1.5 / abs(sin(float(index)/transform)+cos(float(index)/transform));
    


    float value = valueFor(width, height);

    if (value/255 * 5 - 0.5 <= 1.6) {
        buffer[index].color = createEntry(0, 0, 255, 255);
    }else {
        buffer[index].color = createEntry(255 - value, value, (255 - value)/2, 255);
    }


    
//    buffer[index].color = createEntry(float(width)/float(widthValue)*255, float(height)/float(heightValue)*255, (1 - float(width)/float(widthValue))*255, 255);
//    buffer[index].color = createEntry(cos(half(height)/20)*127+127, sin(cos(half(width*height)))*127+127, sin(half(width)/20)*127+127, 255);
//    buffer[index].color = createEntry((zVal)*255, 0, 0, 255);
//    buffer[index].color = createEntry(cos(half(height)/20)*127+127, sin(cos(half(width*height))), sin(half(width)/20)*127+127, 255);
}
