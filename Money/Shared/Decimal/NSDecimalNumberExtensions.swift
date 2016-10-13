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

// MARK: - Equality

public func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.isEqual(to: rhs)
}

// MARK: - Comparable

extension NSDecimalNumber: Comparable { }

public func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

/**
 # NSDecimalNumber Extension
 This is an extension on NSDecimalNumber to support `DecimalNumberType` and
 `Decimal`.

 Note that NSDecimalNumber cannot conform to `DecimalNumberType` directly
 because it is a framework class which cannot be made final, and the protocol
 has functions which return Self.
 */
internal extension NSDecimalNumber {

    var isNegative: Bool {
        return self < NSDecimalNumber.zero
    }

    /**
     Subtract a `NSDecimalNumber` from the receiver.

     - parameter other: another `NSDecimalNumber`.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: a `NSDecimalNumber`.
     */
    
    func subtract(_ other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return subtracting(other, withBehavior: behaviors)
    }

    /**
     Add a `NSDecimalNumber` to the receiver.

     - parameter other: another `NSDecimalNumber`.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: a `NSDecimalNumber`.
     */
    
    func add(_ other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return adding(other, withBehavior: behaviors)
    }

    /**
     Multiply the receive by 10^n

     - parameter n: an `Int` for the 10 power index
     - returns: another instance of this type.
     */
    
    func multiply(byPowerOf10 index: Int, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return multiplying(byPowerOf10: Int16(index), withBehavior: behaviors)
    }

    /**
     Multiply a `NSDecimalNumber` with the receiver.
     
     - parameter other: another `NSDecimalNumber`.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: a `NSDecimalNumber`.
     */
    
    func multiply(by other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return multiplying(by: other, withBehavior: behaviors)
    }

    /**
     Divide the receiver by a matching `NSDecimalNumber`.

     - parameter other: another `NSDecimalNumber`.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: a `NSDecimalNumber`.
     */
    
    func divide(by other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return dividing(by: other, withBehavior: behaviors)
    }

    /**
     Calculates the negative of the receiver.

     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: a `NSDecimalNumber`.
     */
    func negate(withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let negativeOne = NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true)
        let result = multiplying(by: negativeOne, withBehavior: behaviors)
        return result
    }

    /**
     The remainder of dividing another `NSDecimalNumber` into the receiver.
     
     - parameter other: another `NSDecimalNumber`.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: a `NSDecimalNumber`.
     */
    
    func remainder(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let roundingMode: NSDecimalNumber.RoundingMode = (Int(isNegative) ^ Int(other.isNegative)).boolValue ? NSDecimalNumber.RoundingMode.up : NSDecimalNumber.RoundingMode.down
        let roundingBehaviors = NSDecimalNumberHandler(roundingMode: roundingMode, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let quotient = divide(by: other, withBehaviors: roundingBehaviors)
        let toSubtract = quotient.multiply(by: other, withBehaviors: behaviors)
        let result = subtract(toSubtract, withBehaviors: behaviors)

        return result
    }
}


