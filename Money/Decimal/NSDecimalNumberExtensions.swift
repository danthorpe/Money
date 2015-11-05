//
//  NSDecimalNumberExtensions.swift
//  Money
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Daniel Thorpe
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation

// MARK: - NSDecimalNumber

public func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.isEqualToNumber(rhs)
}

public func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

/**
 # NSDecimalNumber Extension
 These is an extension on NSDecimalNumber to support `DecimalNumberType` and
 `Decimal`.

 Note that NSDecimalNumber cannot conform to `DecimalNumberType` directly
 because it is a framework class which cannot be made final, and the protocol
 has functions which return Self.
 */
extension NSDecimalNumber: Comparable {

    public var isNegative: Bool {
        return self < NSDecimalNumber.zero()
    }

    @warn_unused_result
    public func subtract(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberBySubtracting(other, withBehavior: behaviors)
    }

    /**
     Add a matching `DecimalNumberType` to the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func add(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberByAdding(other, withBehavior: behaviors)
    }

    /**
     Multiply a matching `DecimalNumberType` with the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func multiplyBy(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberByMultiplyingBy(other, withBehavior: behaviors)
    }

    /**
     Divide the receiver by a matching `DecimalNumberType`.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func divideBy(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberByDividingBy(other, withBehavior: behaviors)
    }

    public func negateWithBehaviors(behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let negativeOne = NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true)
        let result = decimalNumberByMultiplyingBy(negativeOne, withBehavior: behaviors)
        return result
    }

    /**
     The remainder of dividing another `DecimalNumberType` into the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func remainder(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let roundingMode: NSRoundingMode = Int(isNegative) ^ Int(other.isNegative) ? .RoundUp : .RoundDown
        let roundingBehaviors = NSDecimalNumberHandler(roundingMode: roundingMode, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let quotient = divideBy(other, withBehaviors: roundingBehaviors)
        let toSubtract = quotient.multiplyBy(other, withBehaviors: behaviors)
        let result = subtract(toSubtract, withBehaviors: behaviors)

        return result
    }
}


