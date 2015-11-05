//
//  NSDecimalExtensions.swift
//  Money
//
//  Created by Daniel Thorpe on 05/11/2015.
//
//

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
