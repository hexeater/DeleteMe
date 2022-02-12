#include <metal_stdlib>
using namespace metal;

struct MB_Context
{
    float zoom_x0;
    float zoom_y0;
    float zoom_x1;
    float zoom_y1;
};

constant int maxIterations = 5000;

int iterateMandelbrot (float x0, float y0)
{
    float x = 0.0;
    float y = 0.0;
    float xtemp;

    int iteration = 0;

    do
    {
        xtemp = x*x - y*y + x0;
        y = 2*x*y + y0;
        x = xtemp;
        iteration = iteration + 1;
        
        xtemp = x*x +y*y;
    }
    while(xtemp <= 4.0 && iteration < maxIterations);

    return iteration;
}

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


kernel void clear_pass_func(texture2d<half, access::write> tex [[ texture(0) ]],
                            constant MB_Context * mbContext [[ buffer(0) ]],
                            uint2 id [[ thread_position_in_grid  ]])
{
    //tex.write(half4(mbContext->width, mbContext->height, mbContext->zoom_x0, 1), id);
    
    float zoom_y1 = 1.0-mbContext->zoom_y0;
    float zoom_y0 = 1.0-mbContext->zoom_y1;

    
    float rangeX = mbContext->zoom_x1 - mbContext->zoom_x0;
    //float rangeY = mbContext->zoom_y1 - mbContext->zoom_y0;
    float rangeY = zoom_y1 - zoom_y0;

    float x = mbContext->zoom_x0 + rangeX * (float(id.x) / tex.get_width());
    float y = zoom_y0 + rangeY * (float(id.y) / tex.get_height());

    x = 4.0 * x - 2.0;
    y = 4.0 * y - 2.0;
    
    //float y = thread_position_in_grid / mbContext->width
    int count = iterateMandelbrot(x, y);
    tex.write(mapValueToColor(count, maxIterations), id);
}
