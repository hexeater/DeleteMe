//
//  BigFloatGPU.metal
//  M2
//
//  Created by Joe Albowicz on 2/22/22.
//

#include <metal_stdlib>
using namespace metal;

struct BigFloat
{
    uint blocks[5];
    int numBlocks;
    int numBitsPerBlock;
    bool isPositive;
};

struct MandlebrotContext
{
    // this defines the center point
    BigFloat mbCenterX;
    BigFloat mbCenterY;
    int viewportWidth;
    int viewportHeight;
    int maxIterations;
};



half4 mapValueToColor(float value, float max)
{
  if (value >= max)
  {
      return half4(0.0, 0.0, 0.0, 1.0);
  }

    float A = (1 -value / max) *4.0;

    int G = int(A);
    float F = A-G;
    
    float r = 0.0;
    float g = 0.0;
    float b = 0.0;


  switch (G) {
    case 0:
          r = 1.0;
          g = F;
          break;
    case 1:
          r = 1.0-F;
          g = 1.0;
          break;
    case 2:
          g = 1.0;
//      b = F +(255-F)/2
          b = F;
          break;
    case 3:
          g = 1.0-F;
          b = 1.0;
          break;
  }

    return half4(r, g, b, 1.0);
}



kernel void big_float_squared_difference(constant MandlebrotContext * mb [[ buffer(0) ]],
                                         texture2d<half, access::write> tex [[ texture(0) ]],
                                         uint2 id [[ thread_position_in_grid  ]])
{
    tex.write(mapValueToColor(mb->maxIterations/2, mb->maxIterations), id);
}

kernel void mb_draw(texture2d<half, access::write> tex [[ texture(0) ]],
                          constant MandlebrotContext * mc [[ buffer(0) ]],
                          uint2 id [[ thread_position_in_grid  ]])
{

}
