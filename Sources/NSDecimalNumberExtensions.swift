//
// Money, https://github.com/danthorpe/Money
// Created by Dan Thorpe, @danthorpe
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
     Calculates the negative of the receiver.

     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: a `NSDecimalNumber`.
     */
    func negate(withBehavior behavior: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let negativeOne = NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true)
        let result = multiplying(by: negativeOne, withBehavior: behavior)
        return result
    }

    /**
     The remainder of dividing another `NSDecimalNumber` into the receiver.
     
     - parameter other: another `NSDecimalNumber`.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: a `NSDecimalNumber`.
     */
    func remainder(_ other: NSDecimalNumber, withBehavior behavior: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let a: Int = (isNegative ? 0 : 1)
        let b: Int = (other.isNegative ? 0 : 1)
        let trueOrFalse = (a ^ b) > 0 ? true : false
        let roundingMode: NSDecimalNumber.RoundingMode = trueOrFalse ? NSDecimalNumber.RoundingMode.up : NSDecimalNumber.RoundingMode.down
        let roundingBehaviors = NSDecimalNumberHandler(roundingMode: roundingMode, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let quotient = dividing(by: other, withBehavior: roundingBehaviors)
        let toSubtract = quotient.multiplying(by: other, withBehavior: behavior)
        let result = subtracting(toSubtract, withBehavior: behavior)
        return result
    }
}


