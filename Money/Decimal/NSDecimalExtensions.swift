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

// MARK: - NSDecimal

public func ==(var lhs: NSDecimal, var rhs: NSDecimal) -> Bool {
    return NSDecimalCompare(&lhs, &rhs) == .OrderedSame
}

public func <(var lhs: NSDecimal, var rhs: NSDecimal) -> Bool {
    return NSDecimalCompare(&lhs, &rhs) == .OrderedAscending
}

extension NSDecimal: Comparable {

    public static func zero() -> NSDecimal {
        return NSDecimalNumber.zero().decimalValue
    }

    public static func one() -> NSDecimal {
        return NSDecimalNumber.one().decimalValue
    }

    public var isNegative: Bool {
        return self < NSDecimal.zero()
    }

    internal init() {
        self = NSDecimal.zero()
    }

    @warn_unused_result
    public func subtract(var rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        var lhs = self
        var result = NSDecimal()
        NSDecimalSubtract(&result, &lhs, &rhs, roundingMode)
        return result
    }

    @warn_unused_result
    public func add(var rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        var lhs = self
        var result = NSDecimal()
        NSDecimalAdd(&result, &lhs, &rhs, roundingMode)
        return result
    }

    @warn_unused_result
    public func multiplyBy(var rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        var lhs = self
        var result = NSDecimal()
        NSDecimalMultiply(&result, &lhs, &rhs, roundingMode)
        return result
    }

    @warn_unused_result
    public func divideBy(var rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        var lhs = self
        var result = NSDecimal()
        NSDecimalDivide(&result, &lhs, &rhs, roundingMode)
        return result
    }

    public func negateWithRoundingMode(roundingMode: NSRoundingMode) -> NSDecimal {
        let negativeOne = NSDecimal.zero().subtract(NSDecimal.one(), withRoundingMode: roundingMode)
        let result = multiplyBy(negativeOne, withRoundingMode: roundingMode)
        return result
    }

    @warn_unused_result
    public func remainder(_rhs: NSDecimal, withRoundingMode roundingMode: NSRoundingMode) -> NSDecimal {
        let lhs = NSDecimalNumber(decimal: self)
        let rhs = NSDecimalNumber(decimal: _rhs)
        let behaviors = NSDecimalNumberHandler(roundingMode: roundingMode, scale: 38, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let result = lhs.remainder(rhs, withBehaviors: behaviors)
        return result.decimalValue
    }
}
