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
    float3 storedPosition;
};

constant int width [[function_constant(0)]];
constant int height [[function_constant(1)]];
constant int chunkSize [[function_constant(2)]];

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

float interpolate(Point p1Y, Point p2Y, int Width, int w) {
    return (p2Y.storedPosition.y-p1Y.storedPosition.y)*(float(w)/float(Width))+p1Y.storedPosition.y;
}

kernel void recursiveNoise (device Point* buffer,
                          uint index [[thread_position_in_grid]]) {
    int x = index % width;
    int z = index / width;
    int2 chunk = int2(x / chunkSize,z / chunkSize);
    int2 chunkBottom = int2(chunk.x*chunkSize,chunk.y*chunkSize);
    float3 left = buffer[getIndex(chunkBottom,width)].storedPosition;
    float3 right = buffer[getIndex(chunkBottom, width)+chunkSize].storedPosition;
    if (getIndex(chunkBottom, 0)+chunkSize > width) {
        right = buffer[getIndex(chunkBottom, width)].storedPosition;
    }
    float3 leftT = buffer[getIndex(chunkBottom,width)+width*(chunkSize)].storedPosition;
    float3 rightT = buffer[getIndex(chunkBottom, width)+chunkSize+width*(chunkSize)].storedPosition;
    if (chunkBottom.y + chunkSize > height) {
        leftT = buffer[getIndex(int2(chunkBottom.x,0),width)].storedPosition;
        rightT = buffer[getIndex(int2(chunkBottom.x,0), width)+chunkSize].storedPosition;
        if (chunkSize + chunkBottom.x > width) {
            rightT = buffer[getIndex(int2(0,0), width)+chunkSize+width*chunkSize].storedPosition;
        }
    }
    if (chunkSize + chunkBottom.x + 1 > width) {
        rightT = buffer[getIndex(int2(0,chunkBottom.y), width)+chunkSize+width*chunkSize].storedPosition;
    }
    float topChange = rightT.y - leftT.y;
    float bottomChange = right.y - left.y;
    float leftChange = leftT.y - left.y;
    float rightChange = rightT.y - right.y;
    
    float leftMarker = leftChange * (float(z - chunkBottom.y)/float(chunkSize)) + left.y;
    float rightMarker = rightChange * (float(z - chunkBottom.y)/float(chunkSize)) + right.y;
    
    float topMarker = topChange * (float(x - chunkBottom.x)/float(chunkSize)) + leftT.y;
    float bottomMarker = bottomChange * (float(x - chunkBottom.x)/float(chunkSize)) + left.y;
    
    float topDownValue = (topMarker - bottomMarker)/float(chunkSize) * float(z - chunkBottom.y);
    float leftRightValue = (rightMarker - leftMarker)/float(chunkSize) * float(x - chunkBottom.x);
    
    buffer[index].position.y += (topDownValue + leftRightValue) / 2 / (64 / (chunkSize)) ; //buffer[getIndex(chunk * chunkSize, width)].storedPosition.y / (32/chunkSize)
//    buffer[index].position.y = buffer[index].storedPosition.y;
}
