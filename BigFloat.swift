//
//  BigFloat.swift
//  M2
//
//  Created by Joe Albowicz on 2/16/22.
//

import Foundation

// This float is not general purpose
// it will represent numbers of MB
// ranging from 4 to -4

class BigFloat
{
    var blocks = [UInt](repeating: 0, count: 10000)
    let numBlocks:Int = 10000
    let numBitsPerBlock:Int = 30
    var isPositive:Bool = true

    init()
    {
    }

    init(x:BigFloat)
    {
        isPositive = x.isPositive
        
        for i in 0...numBlocks-1
        {
            blocks[i] = x.blocks[i]
        }
    }
    
    func Negate() -> BigFloat
    {
        let returnValue = BigFloat(x:self)
        returnValue.isPositive = !isPositive
        return returnValue
    }
    
    // Take this current number and subtract x from it.
    func Subtract(x:BigFloat) -> BigFloat
    {
        return Add(x: x.Negate() )
    }
    
    // returns true if |self| is larger than |x|
    // returns false, if they are equal or if |x| is larger
    func CheckAbsoluteValueGreaterThan(x:BigFloat) -> Bool
    {
        for i in 0...numBlocks-1
        {
            // if equal, then check next block
            if blocks[i] == x.blocks[i]
            {
                continue
            }

            return blocks[i] > x.blocks[i]
        }
        
        // if all blocks equal - then return false
        return false
    }
    
    // This function adds the passed number to this instance of BigFloat, returning a new BigFloat
    func Add(x:BigFloat) -> BigFloat
    {
        var resultIsPositive = true
        var doSubtraction = false
        
        if isPositive == false && x.isPositive == false
        {
            // for this case, we can just simply add the numbers same as if they are both positive
            // but do need to set the signage at the the end
            resultIsPositive = false
        }
        else if isPositive == false || x.isPositive == false
        {
            // ok, one of them is negative, but not both.
            // easy way out is to basically subtract the smaller magnitude from the larger magnitude
            if CheckAbsoluteValueGreaterThan(x:x) == false
            {
                return x.Add(x: self)
            }

            // ok this number is larger than x, so we'll subtract instead of add.
            doSubtraction = true
            resultIsPositive = isPositive
        }
        
        let returnValue = BigFloat()
        var overflow = false
        var borrowedOne = false
        let mask:UInt = 1 << numBitsPerBlock
        
        for i in (0...numBlocks-1).reversed()
        {
            if !doSubtraction
            {
                returnValue.blocks[i] = blocks[i] + x.blocks[i]
            }
            else
            {
                var needToBorrowOne = 0
                if blocks[i] < x.blocks[i]
                {
                    // need to borrow...
                    needToBorrowOne = 1<<numBitsPerBlock
                }
                
                returnValue.blocks[i] = UInt(needToBorrowOne) + blocks[i] - x.blocks[i]
                
                if borrowedOne
                {
                    returnValue.blocks[i] = returnValue.blocks[i] - 1
                }
                
                borrowedOne = needToBorrowOne > 0
            }
            
            if overflow
            {
                returnValue.blocks[i] = returnValue.blocks[i] + 1
            }
            
            overflow = (returnValue.blocks[i] & mask) > 0
            
            if overflow
            {
                returnValue.blocks[i] = returnValue.blocks[i] ^ mask
            }
        }

        
            
 //            1111
 //          + 1111
 //          --------
 //           11110
        if resultIsPositive == false
        {
            returnValue.isPositive = false
        }
        
        return returnValue
    }
    
    func SetFloatValue(value:Float)
    {
        if value >= 4.0
        {
            ResetToZero()
            blocks[0] = 4
            return
        }
        if value <= -4.0
        {
            ResetToZero()
            blocks[0] = 4
            isPositive = false
            return
        }
        
        let exponent = Int(value.exponentBitPattern) - 127
        //print("Exponent = ", exponent)

        
        // significand - format is 1.significand
        // + first bit of significand is really 1/2
        // + second bit of significand is 1/4
        // + etc
        
        // Let's reset to the implied 1
        ResetToOne()
        
        isPositive = (value.sign == .plus)
        
        var bitPosition = numBitsPerBlock
        
        for i in 0...22
        {
            let mask = UInt32(1 << (22-i))
            let isSet = (value.significandBitPattern & mask) > 0

            if isSet
            {
                SetBitValue(position: bitPosition, value: isSet)
            }

            bitPosition = bitPosition + 1
        }
        
        if exponent > 0
        {
            for _ in 1...exponent
            {
                MultiplyByTwo()
            }
        }
        
        if exponent < 0
        {
            for _ in 1...(-exponent)
            {
                DivideByTwo()
            }
        }
        
        
    }

    func ResetToZero()
    {
        for b in 0...numBlocks-1
        {
            blocks[b] = 0
        }
    }
    
    func ResetToOne()
    {
        ResetToZero()
        blocks[0] = 1
    }
    
    func DivideByTwo()
    {
        let mask:UInt = 1
        let carryMask:UInt = 1 << (numBitsPerBlock-1)
        var carry = false
        
        for i in (0...numBlocks-1)
        {
            let newCarry = (blocks[i] & mask) > 0
            blocks[i] = blocks[i] >> 1
            
            if carry
            {
                blocks[i] = blocks[i] ^ carryMask
            }
            
            carry = newCarry
        }
    }
    
    
    func MultiplyByTwo()
    {
        let mask:UInt = 1 << numBitsPerBlock
        var carry = false
                
        for i in (0...numBlocks-1).reversed()
        {
            blocks[i] = blocks[i] << 1
            
            if carry
            {
                blocks[i] = blocks[i] + 1
            }
            
            carry = (blocks[i] & mask) > 0
            
            if carry
            {
                blocks[i] = blocks[i] ^ mask
            }
        }
    }
    
    func GetValueAsBinaryString() -> String
    {
        var output = ""
        var leadingZeros = true
        
        // this will display in binary format
        for i in 0...numBlocks-1
        {
            if i == 1
            {
                if output == ""
                {
                    output = "0"
                }
                
                output = output + "."
                leadingZeros = false
            }
            
            for b in (0...numBitsPerBlock-1).reversed()
            {
                if GetBitValue(value: blocks[i], position: b)
                {
                    output = output + "1"
                    leadingZeros = false
                }
                else
                {
                    if leadingZeros == false
                    {
                        output = output + "0"
                    }
                }
            }
            
        }
        
        return output
    }


    func GetBitValue(value:UInt, position:Int) -> Bool
    {
        let mask:UInt = 1 << position
        return (value & mask) > 0
    }

    // This gets a bit from the overall position
    // will be a number from 0 to numBlocks*numBitsPerBlock-1
    func GetBitValue(position:Int) -> Bool
    {
        let index = position / numBitsPerBlock
        var bitPosition = numBitsPerBlock - 1 - position % numBitsPerBlock

        if index == 0
        {
            bitPosition = position % numBitsPerBlock
        }

        var mask:UInt = 1 << bitPosition

        return (blocks[index] & mask) > 0
    }


    func SetBitValue(position:Int, value:Bool)
    {
        let index = position / numBitsPerBlock
        var bitPosition = numBitsPerBlock - 1 - position % numBitsPerBlock

        if index == 0
        {
            bitPosition = position % numBitsPerBlock
        }

        let mask:UInt = ~(1 << bitPosition)
        blocks[index] = blocks[index] & mask
        
        if value
        {
            blocks[index] = blocks[index] + ( 1 << bitPosition )
        }
    }

    func DivideDecimalStringByTwo(value:String, addHalf:Bool) -> String
    {
        //print("DivideDecimalStringByTwo ", "  ", value, ", ", addHalf)
        var output = String("")
        var remainder = Int(addHalf ? 5 : 0)

        for c in value
        {
            let z = ( c.wholeNumberValue! / 2 ) + remainder
            remainder = 5 * (c.wholeNumberValue! % 2)
            
            output = output + String(z)
        }
        
        if remainder > 0
        {
            output = output + String(remainder)
        }

        return output

    }

    func MultiplyDecimalStringByTwo(value:String, addOne:Bool) -> String
    {
        //print("MultiplyDecimalStringByTwo with ", value, ", ", addOne)
        
        var carry = Int(addOne ? 1 : 0)
        var output = String("")
        
        for c in value.reversed()
        {
            let z = c.wholeNumberValue! * 2 + carry
            let x = z % 10

            carry = z / 10
            
            output = String(x) + output
        }
        
        if carry > 0
        {
            output = String(carry) + output
        }
        
        return output
    }
    
    func GetValueAsDecimalString() -> String
    {
        var output = "0"
        
        // First do the > 1 part
        for b in (0...numBitsPerBlock-1).reversed()
        {
            output = MultiplyDecimalStringByTwo(value:output, addOne: GetBitValue(position: b))
        }
        
        output = output + "."
        
        var output2 = "0"

        // Now do the < 1 part
        // we do the least significant bit, then divide by 2 a bunch of times.
        // there probably is a better way...
        for bn in (1...numBlocks-1).reversed()
        {
            for b in (0...numBitsPerBlock-1).reversed()
            {
                output2 = DivideDecimalStringByTwo(value:output2, addHalf: GetBitValue(position: bn * numBitsPerBlock + b))
            }
        }

        output = output + output2

        if isPositive == false
        {
            output = "-" + output
        }

        return output
    }

    func ShiftRight(numPositions:Int) -> BigFloat
    {
        var result = BigFloat()

        // process first block
        for b in (0...(numBitsPerBlock - 1)).reversed()
        {
            var dstIndex = b - numPositions
            
            if dstIndex < 0
            {
                dstIndex =  numBitsPerBlock - 1 - dstIndex
            }

            //print("Looping: ", b, ", ", GetBitValue(position: b), " and setting ", dstIndex)
            result.SetBitValue(position: dstIndex, value: GetBitValue(position: Int(b)))
        }
        
        // process the rest of the blocks
        for b in (numBitsPerBlock...(numBitsPerBlock*numBlocks - 1 - numPositions))
        {
            //print("Looping: ", b, ", ", GetBitValue(position: b), " and setting ", b + numPositions)
            result.SetBitValue(position: b + numPositions, value: GetBitValue(position: b))
        }

      
        result.isPositive = isPositive
        return result
    }

    func ShiftLeft(numPositions:Int) -> BigFloat
    {
        var result = BigFloat()

        // process first block
        for b in (0...(numBitsPerBlock - 1)).reversed()
        {
            var srcIndex = b - numPositions
            
            if srcIndex < 0
            {
                srcIndex =  numBitsPerBlock - 1 - srcIndex
            }

            //print("Looping: ", srcIndex, ", ", GetBitValue(position: srcIndex), " and setting ", b)
            result.SetBitValue(position: b, value: GetBitValue(position: srcIndex))
        }
        
        // process the rest of the blocks
        for b in (numBitsPerBlock...(numBitsPerBlock*numBlocks - 1 - numPositions))
        {
            //print("Looping: ", b, ", ", GetBitValue(position: b), " and setting ", b + numPositions)
            result.SetBitValue(position: b, value: GetBitValue(position: b + numPositions))
        }

      
        result.isPositive = isPositive
        return result
    }

    func Multipy(x:BigFloat) -> BigFloat
    {
        var result = BigFloat()
        
        // Do the stuff to the right of the decimial point first.
        for b in (1...x.numBlocks-1).reversed()
        {
            for i in 0...(x.numBitsPerBlock - 1)
            {
                let srcIndex = b*x.numBitsPerBlock + i
                if x.GetBitValue(position: srcIndex)
                {
                    // OK, this bit is set.  Now time to add it's part to the answer
                    let shifts = srcIndex - numBitsPerBlock + 1
                    let partial = ShiftRight(numPositions: shifts)
                    print("Bit is set ", srcIndex, " >> ", shifts, " partial = ", partial.GetValueAsDecimalString())
                    result = result.Add(x: partial)
                }
            }
        }
        
        for i in 0...(x.numBitsPerBlock - 1)
        {
            if x.GetBitValue(position: i)
            {
                // OK, this bit is set.  Now time to add it's part to the answer
                let partial = ShiftLeft(numPositions: i)
                result = result.Add(x: partial)
            }
        }
        
        result.isPositive = isPositive == x.isPositive
        
        return result
    }
    
}
