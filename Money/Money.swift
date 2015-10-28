//
//  Money.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

/**
 # Money
 
 Money is a value type, which is generic over the currency type.
 
 To work in whatever the local currency is, use `Cash`.

*/
public struct Money<C: CurrencyType> {
    public typealias Currency = C

    internal let value: NSDecimalNumber

    public var isNegative: Bool {
        return value.isNegative
    }

    init(decimalNumber: NSDecimalNumber = NSDecimalNumber.zero()) {
        self.value = decimalNumber
    }
}

/**
 # MoneyType
 `MoneyType` is a protocol which defiens the various operators and
 typealias required to support monetary calculations and operations.

 Some functionality can be be provided via general implementations.
 */
public protocol MoneyType: SignedNumberType, FloatLiteralConvertible, IntegerLiteralConvertible {
    typealias Currency: CurrencyType

    var negative: Self { get }

    @warn_unused_result
    func subtract(_: Self) -> Self

    @warn_unused_result
    func add(_: Self) -> Self

    @warn_unused_result
    func remainder(_: Self) -> Self

    @warn_unused_result
    func multiplyBy(_: NSDecimalNumber) -> Self

    @warn_unused_result
    func divideBy(_: NSDecimalNumber) -> Self
}

// MARK: - Equality

public func ==<C: CurrencyType>(lhs: Money<C>, rhs: Money<C>) -> Bool {
    return lhs.value.compare(rhs.value) == .OrderedSame
}

// MARK: - Comparable

public func <<C: CurrencyType>(lhs: Money<C>, rhs: Money<C>) -> Bool {
    return lhs.value.compare(rhs.value) == .OrderedAscending
}

// MARK: - MoneyType

extension Money: MoneyType {

    public var negative: Money<C> {
        return Money(decimalNumber: value.decimalNumberByMultiplyingBy(NSDecimalNumber.negativeOne, withBehavior: C.decimalNumberBehavior))
    }

    public init(floatLiteral value: FloatLiteralType) {
        self.value = NSDecimalNumber(floatLiteral: value).decimalNumberByRoundingAccordingToBehavior(Currency.decimalNumberBehavior)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        switch value {
        case 0:
            self.value = NSDecimalNumber.zero()
        case 1:
            self.value = NSDecimalNumber.one()
        default:
            self.value = NSDecimalNumber(integerLiteral: value).decimalNumberByRoundingAccordingToBehavior(Currency.decimalNumberBehavior)
        }
    }

    @warn_unused_result
    public func subtract(money: Money<C>) -> Money<C> {
        return Money(decimalNumber: value.decimalNumberBySubtracting(money.value, withBehavior: C.decimalNumberBehavior))
    }

    @warn_unused_result
    public func add(money: Money<C>) -> Money<C> {
        return Money(decimalNumber: value.decimalNumberByAdding(money.value, withBehavior: C.decimalNumberBehavior))
    }

    @warn_unused_result
    public func remainder(divisor: Money<C>) -> Money<C> {
        let roundingMode: NSRoundingMode = Int(isNegative) ^ Int(divisor.isNegative) ? NSRoundingMode.RoundUp : NSRoundingMode.RoundDown
        let behavior = NSDecimalNumberHandler(roundingMode: roundingMode, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let quotient = value.decimalNumberByDividingBy(divisor.value, withBehavior: behavior)
        let subtract = quotient.decimalNumberByMultiplyingBy(divisor.value, withBehavior: C.decimalNumberBehavior)
        let result = value.decimalNumberBySubtracting(subtract, withBehavior: C.decimalNumberBehavior)

        if result.isNegative {
            return Money(decimalNumber: result.decimalNumberByMultiplyingBy(NSDecimalNumber.negativeOne, withBehavior: C.decimalNumberBehavior))
        }

        return Money(decimalNumber: result)
    }

    @warn_unused_result
    public func multiplyBy(by: NSDecimalNumber) -> Money<C> {
        let multiplier = by.decimalNumberByRoundingAccordingToBehavior(C.decimalNumberBehavior)
        let result = value.decimalNumberByMultiplyingBy(multiplier, withBehavior: C.decimalNumberBehavior)
        return Money(decimalNumber: result)
    }

    @warn_unused_result
    public func divideBy(by: NSDecimalNumber) -> Money<C> {
        let divisor = by.decimalNumberByRoundingAccordingToBehavior(C.decimalNumberBehavior)
        let result = value.decimalNumberByDividingBy(divisor, withBehavior: C.decimalNumberBehavior)
        return Money(decimalNumber: result)
    }
}

// MARK: - SignedNumberType / Subtraction

@warn_unused_result
public prefix func -<T: MoneyType>(x: T) -> T {
    return x.negative
}

@warn_unused_result
public func -<T: MoneyType>(lhs: T, rhs: T) -> T {
    return lhs.subtract(rhs)
}

// MARK: - Subtraction

@warn_unused_result
public func -<T: MoneyType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs - T(integerLiteral: rhs)
}

@warn_unused_result
public func -<T: MoneyType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return T(integerLiteral: lhs) - rhs
}

@warn_unused_result
public func -<T: MoneyType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs - T(floatLiteral: rhs)
}

@warn_unused_result
public func -<T: MoneyType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return T(floatLiteral: lhs) - rhs
}

// MARK: - Remainder

@warn_unused_result
public func %<T: MoneyType>(lhs: T, rhs: T) -> T {
    return lhs.remainder(rhs)
}

// MARK: - Addition

@warn_unused_result
public func +<T: MoneyType>(lhs: T, rhs: T) -> T {
    return lhs.add(rhs)
}

@warn_unused_result
public func +<T: MoneyType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs + T(integerLiteral: rhs)
}

@warn_unused_result
public func +<T: MoneyType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return T(integerLiteral: lhs) + rhs
}

@warn_unused_result
public func +<T: MoneyType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs + T(floatLiteral: rhs)
}

@warn_unused_result
public func +<T: MoneyType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return T(floatLiteral: lhs) + rhs
}

// MARK: - Multiplication

@warn_unused_result
public func *<T: MoneyType where T.IntegerLiteralType == Swift.IntegerLiteralType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs.multiplyBy(NSDecimalNumber(integerLiteral: rhs))
}

@warn_unused_result
public func *<T: MoneyType where T.FloatLiteralType == Swift.FloatLiteralType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs.multiplyBy(NSDecimalNumber(floatLiteral: rhs))
}

@warn_unused_result
public func *<T: MoneyType where T.IntegerLiteralType == Swift.IntegerLiteralType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return rhs * lhs
}

@warn_unused_result
public func *<T: MoneyType where T.FloatLiteralType == Swift.FloatLiteralType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return rhs * lhs
}

// MARK: - Division

@warn_unused_result
public func /<T: MoneyType where T.IntegerLiteralType == Swift.IntegerLiteralType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs.divideBy(NSDecimalNumber(integerLiteral: rhs))
}

@warn_unused_result
public func /<T: MoneyType where T.FloatLiteralType == Swift.FloatLiteralType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs.divideBy(NSDecimalNumber(floatLiteral: rhs))
}

