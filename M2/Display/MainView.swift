import MetalKit

struct MB_Context
{    
    // These values range from 0.0 to 1.0
    var zoom_x0: Float
    var zoom_y0: Float
    var zoom_x1: Float
    var zoom_y1: Float
}


class MainView: MTKView, MTKViewDelegate
{
    var mbContext: MB_Context
    var viewport_width: Float
    var viewport_height: Float
    var needsRender = true

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
    {
        mbContext = MB_Context(zoom_x0: 0.0, zoom_y0: 0.0, zoom_x1: 1.0, zoom_y1: 1.0)
        self.viewport_width = Float(size.width)
        self.viewport_height = Float(size.height)
    }
        
    func draw(in view: MTKView)
    {
        if needsRender
        {
            needsRender = false

            guard let drawable = self.currentDrawable else {return}
            
            let commandBuffer = commandQueue.makeCommandBuffer()
            let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
            
            computeCommandEncoder?.setComputePipelineState(clearPass)
            computeCommandEncoder?.setTexture(drawable.texture, index: 0)
            
            let contextBuffer = device?.makeBuffer(bytes: &mbContext, length: MemoryLayout<MB_Context>.stride, options: [])
            
            computeCommandEncoder?.setBuffer(contextBuffer, offset: 0, index: 0)
            
            let w = clearPass.threadExecutionWidth
            let h = clearPass.maxTotalThreadsPerThreadgroup / w
            
            let threadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
            let threadsPerGrid = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
            computeCommandEncoder?.dispatchThreads(threadsPerGrid,
                                                   threadsPerThreadgroup: threadsPerThreadGroup)
            
            
            computeCommandEncoder?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
    
    var commandQueue: MTLCommandQueue!
    var clearPass: MTLComputePipelineState!

    required init(coder: NSCoder)
    {
        mbContext = MB_Context(zoom_x0: 0.0, zoom_y0: 0.0, zoom_x1: 1.0, zoom_y1: 1.0)
        self.viewport_width = 1.0
        self.viewport_height = 1.0

        super.init(coder: coder)

        self.viewport_width = Float(self.drawableSize.width)
        self.viewport_height = Float(self.drawableSize.height)

        self.delegate = self
        self.framebufferOnly = false
        self.device = MTLCreateSystemDefaultDevice()
        
        self.commandQueue = device?.makeCommandQueue()
        
        let library = device?.makeDefaultLibrary()
        let clearFunc = library?.makeFunction(name: "clear_pass_func")
        
        do
        {
            clearPass = try device?.makeComputePipelineState(function: clearFunc!)
        }
        catch let error as NSError {
            print(error)
        }
        
    }

    override var acceptsFirstResponder:Bool { return true}

    override func keyUp(with event: NSEvent)
    {
        print("Key Up!")
    }

    override func mouseUp(with event: NSEvent)
    {
        // I hate swift syntax....
        let shiftKeyPressed = (event.modifierFlags.rawValue & 2) != 0
        
        var zoom_x0 = mbContext.zoom_x0
        var zoom_y0 = mbContext.zoom_y0
        var zoom_x1 = mbContext.zoom_x1
        var zoom_y1 = mbContext.zoom_y1
        
        
        let mouseX = Float(2.0 * event.locationInWindow.x)
        let mouseY = Float(2.0 * event.locationInWindow.y)
        print("Actual Mouse location")
        print(event.locationInWindow)
        
        //let mouseX = Float(viewport_width/2)
        //let mouseY = Float(viewport_height/2)

        print("Mouse up!")
        print(mouseX, ",", mouseY)
        print(shiftKeyPressed)

        //let local_point = self.convert(event.locationInWindow, from:self)
        //print(local_point)
        
        print("Current View Port:")
        print(viewport_width, ",", viewport_height)
        
        print("Current Zoom window:")
        print(zoom_x0, ",", zoom_y0)
        print(zoom_x1, ",", zoom_y1)

        let px = mouseX / viewport_width
        let py = mouseY / viewport_height
        let currentZoomDistanceX = zoom_x1 - zoom_x0
        let currentZoomDistanceY = zoom_y1 - zoom_y0
        print("px, py are:  ", px, ", ", py)
        print("currentZoomDistanceX:  ", currentZoomDistanceX)
        print("currentZoomDistanceY:  ", currentZoomDistanceY)

        let centerX = zoom_x0 + currentZoomDistanceX / 2
        let deltaX = px * currentZoomDistanceX + zoom_x0 - centerX

        let centerY = zoom_y0 + currentZoomDistanceY / 2
        let deltaY = py * currentZoomDistanceY + zoom_y0 - centerY

        // First adjust the coordinates so they are centered on the click
        zoom_x0 = zoom_x0 + deltaX
        zoom_x1 = zoom_x0 + currentZoomDistanceX

        zoom_y0 = zoom_y0 + deltaY
        zoom_y1 = zoom_y0 + currentZoomDistanceY

        // Now zoom
        var newZoomDistanceX = currentZoomDistanceX/2
        var zoomDx = currentZoomDistanceX/4

        var newZoomDistanceY = currentZoomDistanceY/2
        var zoomDy = currentZoomDistanceY/4

        if(shiftKeyPressed)
        {
            newZoomDistanceX = currentZoomDistanceX*2
            if(newZoomDistanceX > 1.0)
            {
                newZoomDistanceX = 1.0
            }
            
            zoomDx = -newZoomDistanceX/4

            newZoomDistanceY = currentZoomDistanceY*2
            if(newZoomDistanceY > 1.0)
            {
                newZoomDistanceY = 1.0
            }
            zoomDy = -newZoomDistanceY/4
        }
        
        zoom_x0 = zoom_x0 + zoomDx
        zoom_x1 = zoom_x1 - zoomDx

        zoom_y0 = zoom_y0 + zoomDy
        zoom_y1 = zoom_y1 - zoomDy

        // Fix edge conditions
        if(zoom_x0 < 0)
        {
          zoom_x0 = 0
          zoom_x1 = zoom_x0 + newZoomDistanceX
        }

        if(zoom_x1 > 1.0)
        {
            zoom_x1 = 1.0
          zoom_x0 = zoom_x1 - newZoomDistanceX
        }

        if(zoom_y0 < 0)
        {
          zoom_y0 = 0
          zoom_y1 = zoom_y0 + newZoomDistanceY
        }

        if(zoom_y1 > 1.0)
        {
            print("Adjusting here:  ")
            print(zoom_y1)
            zoom_y1 = 1.0
            print(zoom_y1)
            print(newZoomDistanceY)
          zoom_y0 = zoom_y1 - newZoomDistanceY
        }

        print("New Zoom window:")
        print(zoom_x0, ", ", zoom_y0)
        print(zoom_x1, ", ", zoom_y1)
        
        mbContext.zoom_x0 = zoom_x0
        mbContext.zoom_y0 = zoom_y0
        mbContext.zoom_x1 = zoom_x1
        mbContext.zoom_y1 = zoom_y1
        
        needsRender = true
    }
}


