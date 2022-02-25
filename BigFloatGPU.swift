//
//  BigFloatGPU.swift
//  M2
//
//  Created by Joe Albowicz on 2/22/22.
//

import Foundation
import MetalKit


class BigFloatGPU
{
    var commandQueue: MTLCommandQueue!
    var device: MTLDevice!
    var bigFloatAddPipelineState: MTLComputePipelineState!


    static let shared = BigFloatGPU()

    // Initialization

    private init()
    {
        print("BigFloatGPU.init()")
        
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
        let library = device?.makeDefaultLibrary()
        let bfaFunc = library?.makeFunction(name: "big_float_squared_difference")

        do
        {
            bigFloatAddPipelineState = try device?.makeComputePipelineState(function: bfaFunc!)
        }
        catch let error as NSError {
            print(error)
        }

    }
    
    func something()
    {
        print("Hello!")
    }

}

