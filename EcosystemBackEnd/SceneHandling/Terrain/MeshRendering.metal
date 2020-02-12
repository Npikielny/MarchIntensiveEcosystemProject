//
//  MeshRendering.metal
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 1/24/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Point {
    float3 position;
};

constant int width [[function_constant(0)]];
constant int height [[function_constant(1)]];

bool exists (int x, int y, int shiftX, int shiftY, int Width, int height) {
    if (x + shiftX > 0 && x + shiftX < Width && y + shiftY > 0 && y + shiftY < height) {
        return true;
    }else {
        return false;
    }
}


int getIndex(int2 point, int Width) {
    int xCoord = point.x;
    int yCoord = point.y;
    return yCoord*Width+xCoord;
}

float interpolate(float a, float b, float x) {
    half ft = x * acos(half(0));
    half f = (1.0-cos(ft)) * 0.5;
    return float(a*(1.0-f)+b*f);
}

int overFlowMultiplication(int int_1, int int_2) {
    half pwr = 63;
    int max = int(pow(half(2), pwr-1));
    if (int_1*int_2 % (max * 2) > max) {
        return (int_1*int_2 % max - max);
    }else {
        return (int_1*int_2 % max);
    }
}

float findNoise(half x, half y) {
    
    int noiseX = 1619;
    int noiseY = 31337;
    int noiseSeed = 1013;
    
    int n = (noiseX*int(x) + noiseY*int(y) + noiseSeed * 1) & 0x7fffffff;
    
    n = (n >> 13) ^ n;
    n = (overFlowMultiplication(n,overFlowMultiplication(n,overFlowMultiplication(n, 60493) + 19990303) + 1376312589)) & 0x7fffffff;
    
    return float(1.0) - float(n)/float(1073741824);
}

half noise(half x, half y) {
    half floorX = half(int(x));
    half floorY = half(int(y));
    
    half s = findNoise(floorX, floorY);
    half t = findNoise(floorX+1, floorY);
    half u = findNoise(floorX, floorY+1);
    half v = findNoise(floorX+1, floorY+1);
    
    
    half i1 = interpolate(s, t, x-floorX);
    half i2 = interpolate(u, v, x-floorX);
    
    return interpolate(i1, i2, y-floorY);
}

kernel void perlin (device Point* buffer,
                            uint index [[thread_position_in_grid]]) {
    int x = index % width;
    int z = index / width;
    
    int octaves = 4;
    half p = 0.25;
    half zoom = 24.0;
    float getnoise = 0;
    
    for (int a = 0; a < octaves-1; a ++) {
        half frequency = pow(half(2), half(a));
        half amplitude = pow(p, half(a));
        getnoise += noise((half(x))*frequency/zoom, (half(z))/zoom*frequency)*amplitude;
        buffer[index].position.y = noise((half(x))*frequency/zoom, (half(z))/zoom*frequency)*amplitude;
    }

    float value = float(((getnoise*5)+5));
//
//    if (value > 5) {
//        value = 5;
//    }
//    else if (value < 0) {
//        value = 0;
//    }
    buffer[index].position.y = value;
}
