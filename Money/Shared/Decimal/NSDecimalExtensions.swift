//
//  NSDecimalExtensions.swift
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

// MARK: - Equality

public func == (lhs: NSDecimal, rhs: NSDecimal) -> Bool {
    var (lhs, rhs) = (lhs, rhs)
    return NSDecimalCompare(&lhs, &rhs) == .OrderedSame
}

// MARK: - Comparable

extension NSDecimal: Comparable { }

public func < (lhs: NSDecimal, rhs: NSDecimal) -> Bool {
    var (lhs, rhs) = (lhs, rhs)
    return NSDecimalCompare(&lhs, &rhs) == .OrderedAscending
}

/**
 # NSDecimal Extension

 This is an extension on NSDecimal to support `DecimalNumberType` and
 `Decimal`.
 */
internal extension NSDecimal {

    /**
     Static function to get the `NSDecimal` representation of 
     zero.
     
     - returns: a `NSDecimal` of zero.
    */
    static func zero() -> NSDecimal {
        return NSDecimalNumber.zero().decimalValue
    }

    /**
     Static function to get the `NSDecimal` representation of
     positive one.

     - returns: a `NSDecimal` of one.
     */
    static func one() -> NSDecimal {
        return NSDecimalNumber.one().decimalValue
    }

    /**
     Boolean flag to indicate if the receive is a negative
     number.
     
     - returns: a `Bool` if the value is below zero.
    */
    var isNegative: Bool {
        return self < NSDecimal.zero()
    }

    internal init() {
        self = NSDecimal.zero()
    }

    /**
     Subtract a `NSDecimal` from the receiver.

     - parameter other: another `NSDecimal`.
     - parameter roundingMode: the NSRoundingMode to use for the calculation.
     - returns: a `NSDecimal`.
     */
    @warn_unused_result
    func subtract(rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        var (lhs, rhs) = (self, rhs)
        var result = NSDecimal()
        NSDecimalSubtract(&result, &lhs, &rhs, roundingMode)
        return result
    }

    /**
     Add a `NSDecimal` to the receiver.

     - parameter other: another `NSDecimal`.
     - parameter roundingMode: the NSRoundingMode to use for the calculation.
     - returns: a `NSDecimal`.
     */
    @warn_unused_result
    func add(rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        var (lhs, rhs) = (self, rhs)
        var result = NSDecimal()
        NSDecimalAdd(&result, &lhs, &rhs, roundingMode)
        return result
    }

    /**
     Multiply a `NSDecimal` with the receiver.

     - parameter other: another `NSDecimal`.
     - parameter roundingMode: the NSRoundingMode to use for the calculation.
     - returns: a `NSDecimal`.
     */
    @warn_unused_result
    func multiplyBy(rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        var (lhs, rhs) = (self, rhs)
        var result = NSDecimal()
        NSDecimalMultiply(&result, &lhs, &rhs, roundingMode)
        return result
    }

    /**
     Divide the receiver by a matching `NSDecimal`.

     - parameter other: another `NSDecimal`.
     - parameter roundingMode: the NSRoundingMode to use for the calculation.
     - returns: a `NSDecimal`.
     */
    @warn_unused_result
    func divideBy(rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        var (lhs, rhs) = (self, rhs)
        var result = NSDecimal()
        NSDecimalDivide(&result, &lhs, &rhs, roundingMode)
        return result
    }

    /**
     Calculates the negative of the receiver.

     - parameter roundingMode: the NSRoundingMode to use for the calculation.
     - returns: a `NSDecimal`.
     */
    func negateWithRoundingMode(roundingMode: NSRoundingMode) -> NSDecimal {
        let negativeOne = NSDecimal.zero().subtract(NSDecimal.one(), withRoundingMode: roundingMode)
        let result = multiplyBy(negativeOne, withRoundingMode: roundingMode)
        return result
    }

    /**
     The remainder of dividing another `NSDecimal` into the receiver.

     - parameter other: another `NSDecimal`.
     - parameter roundingMode: the NSRoundingMode to use for the calculation.
     - returns: a `NSDecimal`.
     */
    @warn_unused_result
    func remainder(_rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        let lhs = NSDecimalNumber(decimal: self)
        let rhs = NSDecimalNumber(decimal: _rhs)
        let behaviors = NSDecimalNumberHandler(roundingMode: roundingMode, scale: 38, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let result = lhs.remainder(rhs, withBehaviors: behaviors)
        return result.decimalValue
    }
}
