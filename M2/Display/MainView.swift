
// Idea.  develop arthimetic operations for +, -, *, /
// where the operands are represented by array of floating point numbers
// where first float is the first N digits, second float is second N digits, etc.
// Plus would be easy, just have to implement carry logic
// Subtraction is easy
// Multiplication is easy too...
// I guess division has to emulate paper and pencil...

import MetalKit

struct MB_Context
{    
    // These values range from 0.0 to 1.0
    var zoom_x0: Float
    var zoom_y0: Float
    var zoom_x1: Float
    var zoom_y1: Float
    var maxIterations: Int
}


class MainView: MTKView, MTKViewDelegate
{
    @IBOutlet weak var IterationCount: NSTextField!
    @IBOutlet weak var ZoomLevel: NSTextField!
    @IBOutlet weak var UpdateButton: NSButton!
    
    var mbContext: MB_Context
    var viewport_width: Float
    var viewport_height: Float
    var needsRender = true
    var maxIterations = 250
    var zoomLevel:Float = 1.0

    func dumpPrecisionInfoForLevel()
    {
        let zmPow = pow(2.0, -zoomLevel)
        print("*********************dumpPrecisionInfoForLevel")
        print("Type of zoomLevel is:  ", type(of:zoomLevel))
        print("Float.leastNonzeroMagnitude is:  ", Float.leastNonzeroMagnitude)
        print("Zoom level is ", zoomLevel)
        print("2^(-ZL) = ", zmPow)
        print("Type of zmPow is:  ", type(of:zmPow))
        print("using this Width/Height: ", viewport_width, ",  ", viewport_height)
        
        print("Zoom Window currently is: ")
        print(mbContext)

        print("AS FLOAT")
        evaluateCurrentMetalPrecision()
        print("AS refactor")
        evaluateRefactorMetalPrecision()

        
        print("Done ****************dumpPrecisionInfoForLevel")
    }
 
    func evaluateCurrentMetalPrecisionAsDouble()
    {
        // sample data for metal computation
        var metal_id_x:Double = 3.0
        var metal_id_y:Double = 3.0

        var metal_id_x1:Double = 4.0
        var metal_id_y1:Double = 4.0

        // computation from Metal file
        var metal_zoom_y1:Double = Double(1.0 - mbContext.zoom_y0)
        var metal_zoom_y0:Double = Double(1.0 - mbContext.zoom_y1)


        var metal_rangeX:Double = Double(mbContext.zoom_x1 - mbContext.zoom_x0)
        var metal_rangeY:Double = metal_zoom_y1 - metal_zoom_y0;

        var metal_x:Double = Double(mbContext.zoom_x0) + metal_rangeX * (metal_id_x / Double(viewport_width))
        var metal_y:Double = metal_zoom_y0 + metal_rangeY * (metal_id_y / Double(viewport_height))

        var metal_x1:Double = Double(mbContext.zoom_x0) + metal_rangeX * (metal_id_x1 / Double(viewport_width))
        var metal_y1:Double = metal_zoom_y0 + metal_rangeY * (metal_id_y1 / Double(viewport_height))

        metal_x = 4.0 * metal_x - 2.0;
        metal_y = 4.0 * metal_y - 2.0;

        metal_x1 = 4.0 * metal_x1 - 2.0;
        metal_y1 = 4.0 * metal_y1 - 2.0;

        print("metal_x_y:  ", metal_x, ", ", metal_y)
        print("metal_x1_y1:  ", metal_x1, ", ", metal_y1)

        var dx = metal_x1 - metal_x
        var dy = metal_y1 - metal_y
        
        print("DX: ", dx)
        print("DY: ", dy)

        print("rangeX / width: ", metal_rangeX / Double(viewport_width))
        print("rangeY / height: ", metal_rangeY / Double(viewport_height))
        // computation from metal file is above here...


    }

    
    func evaluateCurrentMetalPrecision()
    {
        // sample data for metal computation
        var metal_id_x:Float = 3.0
        var metal_id_y:Float = 3.0

        var metal_id_x1:Float = 4.0
        var metal_id_y1:Float = 4.0

        // computation from Metal file
        var metal_zoom_y1:Float = 1.0 - mbContext.zoom_y0
        var metal_zoom_y0:Float = 1.0 - mbContext.zoom_y1


        var metal_rangeX:Float = mbContext.zoom_x1 - mbContext.zoom_x0
        var metal_rangeY:Float = metal_zoom_y1 - metal_zoom_y0;

        var metal_x:Float = mbContext.zoom_x0 + metal_rangeX * (metal_id_x / viewport_width)
        var metal_y:Float = metal_zoom_y0 + metal_rangeY * (metal_id_y / viewport_height)

        var metal_x1:Float = mbContext.zoom_x0 + metal_rangeX * (metal_id_x1 / viewport_width)
        var metal_y1:Float = metal_zoom_y0 + metal_rangeY * (metal_id_y1 / viewport_height)

        // Before scaling
        print("Before scaling")
        print("metal_x_y:  ", metal_x, ", ", metal_y)
        print("metal_x1_y1:  ", metal_x1, ", ", metal_y1)

        var dx = metal_x1 - metal_x
        var dy = metal_y1 - metal_y
        
        print("DX: ", dx)
        print("DY: ", dy)

        print("rangeX / width: ", metal_rangeX / viewport_width)
        print("rangeY / height: ", metal_rangeY / viewport_height)

        
        
        metal_x = 4.0 * metal_x - 2.0;
        metal_y = 4.0 * metal_y - 2.0;

        metal_x1 = 4.0 * metal_x1 - 2.0;
        metal_y1 = 4.0 * metal_y1 - 2.0;

        print("After Scaling")
        print("metal_x_y:  ", metal_x, ", ", metal_y)
        print("metal_x1_y1:  ", metal_x1, ", ", metal_y1)

         dx = metal_x1 - metal_x
         dy = metal_y1 - metal_y
        
        print("DX: ", dx)
        print("DY: ", dy)

        print("rangeX / width: ", 4.0 * metal_rangeX / viewport_width)
        print("rangeY / height: ", 4.0 * metal_rangeY / viewport_height)
        // computation from metal file is above here...


    }
  
    func evaluateRefactorMetalPrecision()
    {
        // sample data for metal computation
        var metal_id_x:Float = 3.0
        var metal_id_y:Float = 3.0

        var metal_id_x1:Float = 4.0
        var metal_id_y1:Float = 4.0

        // computation from Metal file
        var metal_zoom_y1:Float = 1.0 - mbContext.zoom_y0
        var metal_zoom_y0:Float = 1.0 - mbContext.zoom_y1


        var metal_rangeX:Float = mbContext.zoom_x1 - mbContext.zoom_x0
        var metal_rangeY:Float = metal_zoom_y1 - metal_zoom_y0;

        var metal_x:Float = mbContext.zoom_x0 + metal_id_x * (metal_rangeX / viewport_width )
        var metal_y:Float = metal_zoom_y0 + metal_id_y * ( metal_rangeY / viewport_height )
        
        var metal_x1:Float = mbContext.zoom_x0 + metal_id_x1 * (metal_rangeX / viewport_width )
        var metal_y1:Float = metal_zoom_y0 + metal_id_y1 * ( metal_rangeY / viewport_height )


        metal_x = 4.0 * metal_x - 2.0;
        metal_y = 4.0 * metal_y - 2.0;

        metal_x1 = 4.0 * metal_x1 - 2.0;
        metal_y1 = 4.0 * metal_y1 - 2.0;

        print("metal_x_y:  ", metal_x, ", ", metal_y)
        print("metal_x1_y1:  ", metal_x1, ", ", metal_y1)

        var dx = metal_x1 - metal_x
        var dy = metal_y1 - metal_y
        
        print("DX: ", dx)
        print("DY: ", dy)

        print("rangeX / width: ", 4.0 * metal_rangeX / viewport_width)
        print("rangeY / height: ", 4.0 * metal_rangeY / viewport_height)
        // computation from metal file is above here...


    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
    {
        mbContext = MB_Context(zoom_x0: 0.0, zoom_y0: 0.0, zoom_x1: 1.0, zoom_y1: 1.0, maxIterations: maxIterations)
        self.viewport_width = Float(size.width)
        self.viewport_height = Float(size.height)
    }
        
    func draw(in view: MTKView)
    {
        if needsRender
        {
            needsRender = false

            guard let drawable = self.currentDrawable else {return}
            
            print("here is the drawable width/height")
            print(drawable.texture.width)
            print(drawable.texture.height)

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
        mbContext = MB_Context(zoom_x0: 0.0, zoom_y0: 0.0, zoom_x1: 1.0, zoom_y1: 1.0, maxIterations:maxIterations)
        self.viewport_width = 1.0
        self.viewport_height = 1.0

        super.init(coder: coder)

        IterationCount?.stringValue = "250"
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
            zoomLevel = zoomLevel - 1
            
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
        else
        {
            zoomLevel = zoomLevel + 1
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
        
        ZoomLevel.stringValue = String(zoomLevel)
        
        dumpPrecisionInfoForLevel()
    }
    
    
    @IBAction func buttonUpdate(_ sender: Any)
    {
        let value = Int(IterationCount.stringValue)
        print(value ?? -1)
        
        maxIterations = value!

/*        mbContext = MB_Context(zoom_x0: 0.0, zoom_y0: 0.0,
                               zoom_x1: 1.0, zoom_y1: 1.0,
                               maxIterations: maxIterations) */
        
        mbContext.maxIterations = value!

        dumpPrecisionInfoForLevel()

        needsRender = true
        
    }

    @IBAction func CalculateStuff(_ sender: Any)
    {

        print("Hello")

    }

    
}





