//
//  M2Tests.swift
//  M2Tests
//
//  Created by Joe Albowicz on 2/18/22.
//

import XCTest
@testable import M2

class M2Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBigFloatGPU() throws
    {
        BigFloatGPU.shared.something()
    }
    
    
    func testFloatScratchArea() throws
    {
        
        print("now let's try 0.529296875")
        let num = BigFloat()

        num.SetFloatValue(value: 0.529296875)
        var numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.529296875")

        num.SetFloatValue(value: 1.0)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.0")

        num.SetFloatValue(value: 0.0)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.0")

    }

    func testNegativeNumbers() throws
    {
        
        var num = BigFloat()

        num.SetFloatValue(value: -0.529296875)
        var numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-0.529296875")

        num.SetFloatValue(value: -1.0)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-1.0")
    }


    func testSimpleFloat() throws
    {
        
        print("now let's try 2.75")
        var num = BigFloat()
        num.SetFloatValue(value: 2.75)
        let binStr = num.GetValueAsBinaryString()
        let numStr = num.GetValueAsDecimalString()
        
        print(binStr)
        print(numStr)

        XCTAssertEqual(binStr, "10.110000000000000000000000000000000000000000000000000000000000")
        XCTAssertEqual(numStr, "2.75")

    }

    func testSubtract() throws
    {
        var num = BigFloat()
        num.SetFloatValue(value: 0.0001220703125)
        var numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.0001220703125")
        
        var num2 = BigFloat()
        num2.SetFloatValue(value: 0.0009765625)
        
        numStr = num2.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.0009765625")


        var resultAdd = num.Add(x: num2)
        numStr = resultAdd.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.0010986328125")

        
        var num3 = num2.Negate()
        var result = num3.Add(x: num)
        print(num3.GetValueAsDecimalString(), " + ", num.GetValueAsDecimalString(), " = ", result.GetValueAsDecimalString())
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-0.0008544921875")

        
        result = num.Subtract(x: num2)
        print(num.GetValueAsDecimalString(), " - ", num2.GetValueAsDecimalString(), " = ", result.GetValueAsDecimalString())
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-0.0008544921875")

    }

    func testSettingBits()
    {
        let num = BigFloat()
        num.SetBitValue(position: 0, value: true)
        var numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.0")

        
        num.SetBitValue(position: num.numBitsPerBlock, value: true)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.5")

    }
    
    func testShiftRight()
    {
        let num = BigFloat()
        num.SetFloatValue(value: 1.0)
        var numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.0")

        var result = num.ShiftRight(numPositions: 1)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.5")

        
        
        num.SetFloatValue(value: 4.0)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "4.0")
        result = num.ShiftRight(numPositions: 2)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.0")

        num.SetFloatValue(value: 3.0)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "3.0")
        result = num.ShiftRight(numPositions: 1)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.5")


        
        
        num.SetFloatValue(value: 2.25)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "2.25")

        result = num.ShiftRight(numPositions: 1)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.125")


        num.SetFloatValue(value: -2.25)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-2.25")

        result = num.ShiftRight(numPositions: 1)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-1.125")

    }

    func testMultiply()
    {
        let num = BigFloat()
        num.SetFloatValue(value: 0.5)
        var numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.5")

        var result = num.Multipy(x: num)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.25")

        num.SetFloatValue(value: 1.5)
        result = num.Multipy(x: num)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "2.25")

        
        num.SetFloatValue(value: -0.0625)
        result = num.Multipy(x: num)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.00390625")

        num.SetFloatValue(value: 2.34)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        result = num.Multipy(x: num)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "5.4756")
        
    }
    
    func testShiftLeft()
    {
        let num = BigFloat()
        num.SetFloatValue(value: 1.0)
        var numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.0")

        var result = num.ShiftLeft(numPositions: 1)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "2.0")

        
        num.SetFloatValue(value: 1.5)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.5")
        result = num.ShiftLeft(numPositions: 1)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "3.0")

        
        num.SetFloatValue(value: 0.09375)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.09375")
        result = num.ShiftLeft(numPositions: 5)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "3.0")

        num.SetFloatValue(value: 0.09375)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.09375")
        result = num.ShiftLeft(numPositions: 20)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.0")

        num.SetFloatValue(value: -0.09375)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-0.09375")
        result = num.ShiftLeft(numPositions: 0)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-0.09375")

/*
        
        num.SetFloatValue(value: 4.0)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "4.0")
        result = num.ShiftRight(numPositions: 2)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.0")

        num.SetFloatValue(value: 3.0)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "3.0")
        result = num.ShiftRight(numPositions: 1)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.5")


        
        
        num.SetFloatValue(value: 2.25)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "2.25")

        result = num.ShiftRight(numPositions: 1)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "1.125")


        num.SetFloatValue(value: -2.25)
        numStr = num.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-2.25")

        result = num.ShiftRight(numPositions: 1)
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-1.125") */

    }
 
    
    
    
    
    
    func testAddFloat() throws
    {
        var num = BigFloat()
        num.SetFloatValue(value: 2.75)

        var binStr = num.GetValueAsBinaryString()
        var numStr = num.GetValueAsDecimalString()
        print(binStr)
        print(numStr)
        XCTAssertEqual(numStr, "2.75")
        
        var num2 = BigFloat()
        num2.SetFloatValue(value: 0.529296875)
        
        binStr = num2.GetValueAsBinaryString()
        numStr = num2.GetValueAsDecimalString()
        print(binStr)
        print(numStr)
        XCTAssertEqual(numStr, "0.529296875")

        
        var result = num.Add(x: num2)
        
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "3.279296875")

        
        var num3 = BigFloat()
        num3.SetFloatValue(value: -3.0)
        
        numStr = num3.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-3.0")

        
        result = num.Add(x: num3)
        
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-0.25")

        
        result = num2.Add(x: num3)
        
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-2.470703125")

        
        var num4 = BigFloat()
        num4.SetFloatValue(value: 0.208984375)
        
        numStr = num4.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "0.208984375")

        
        result = num4.Add(x: num3)
        
        numStr = result.GetValueAsDecimalString()
        print(numStr)
        XCTAssertEqual(numStr, "-2.791015625")

        
        
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
