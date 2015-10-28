//
//  Money.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

protocol MoneyType: SignedNumberType {
    typealias Currency: CurrencyType
}

/**
 # Money
 
 Money is a value type, which is generic over the currency type.
 
 To work in whatever the local currency is, use `Cash`.

*/
public struct Money<C: CurrencyType>: MoneyType {
    typealias Currency = C

    internal let value: NSDecimalNumber

    public var isNegative: Bool {
        return value.isNegative
    }

    init(decimalNumber: NSDecimalNumber = NSDecimalNumber.zero()) {
        self.value = decimalNumber
    }
}

public typealias Cash = Money<LocalCurrency>

// MARK: - Literal Convertibles

extension Money: FloatLiteralConvertible {

    public init(floatLiteral value: FloatLiteralType) {
        self.value = NSDecimalNumber(floatLiteral: value).decimalNumberByRoundingAccordingToBehavior(Currency.decimalNumberBehavior)
    }
}

extension Money: IntegerLiteralConvertible {

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
}

// MARK: - Equality

public func ==<C: CurrencyType>(lhs: Money<C>, rhs: Money<C>) -> Bool {
    return lhs.value.compare(rhs.value) == .OrderedSame
}

// MARK: - Comparable

public func <<C: CurrencyType>(lhs: Money<C>, rhs: Money<C>) -> Bool {
    return lhs.value.compare(rhs.value) == .OrderedAscending
}

// MARK: - SignedNumberType

public func -<C: CurrencyType>(lhs: Money<C>, rhs: Money<C>) -> Money<C> {
    return Money(decimalNumber: lhs.value.decimalNumberBySubtracting(rhs.value, withBehavior: C.decimalNumberBehavior))
}

public prefix func -<C: CurrencyType>(x: Money<C>) -> Money<C> {
    let behavior = C.decimalNumberBehavior
    return Money(decimalNumber: x.value.decimalNumberByMultiplyingBy(NSDecimalNumber.negativeOne, withBehavior: behavior))
}

// MARK: - Addition

public func +<C: CurrencyType>(lhs: Money<C>, rhs: Money<C>) -> Money<C> {
    return Money(decimalNumber: lhs.value.decimalNumberByAdding(rhs.value, withBehavior: C.decimalNumberBehavior))
}

// MARK: - Remainder

public func %<C: CurrencyType>(dividend: Money<C>, divisor: Money<C>) -> Money<C> {

    let roundingMode: NSRoundingMode = Int(dividend.isNegative) ^ Int(divisor.isNegative) ? NSRoundingMode.RoundUp : NSRoundingMode.RoundDown
    let behavior = NSDecimalNumberHandler(roundingMode: roundingMode, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    let quotient = dividend.value.decimalNumberByDividingBy(divisor.value, withBehavior: behavior)
    let subtract = quotient.decimalNumberByMultiplyingBy(divisor.value, withBehavior: C.decimalNumberBehavior)
    let value = dividend.value.decimalNumberBySubtracting(subtract, withBehavior: C.decimalNumberBehavior)

    if value.isNegative {
        return Money(decimalNumber: value.decimalNumberByMultiplyingBy(NSDecimalNumber.negativeOne, withBehavior: C.decimalNumberBehavior))
    }

    return Money(decimalNumber: value)
}

// MARK: - Multiplication

public func *<C: CurrencyType>(lhs: Money<C>, rhs: IntegerLiteralType) -> Money<C> {
    let factor = NSDecimalNumber(integerLiteral: rhs).decimalNumberByRoundingAccordingToBehavior(C.decimalNumberBehavior)
    let value = lhs.value.decimalNumberByMultiplyingBy(factor, withBehavior: C.decimalNumberBehavior)
    return Money(decimalNumber: value)
}

public func *<C: CurrencyType>(lhs: Money<C>, rhs: FloatLiteralType) -> Money<C> {
    let factor = NSDecimalNumber(floatLiteral: rhs).decimalNumberByRoundingAccordingToBehavior(C.decimalNumberBehavior)
    let value = lhs.value.decimalNumberByMultiplyingBy(factor, withBehavior: C.decimalNumberBehavior)
    return Money(decimalNumber: value)
}

public func *<C: CurrencyType>(lhs: IntegerLiteralType, rhs: Money<C>) -> Money<C> {
    return rhs * lhs
}

public func *<C: CurrencyType>(lhs: FloatLiteralType, rhs: Money<C>) -> Money<C> {
    return rhs * lhs
}

// MARK: - Division

public func /<C: CurrencyType>(lhs: Money<C>, rhs: IntegerLiteralType) -> Money<C> {
    let divisor = NSDecimalNumber(integerLiteral: rhs).decimalNumberByRoundingAccordingToBehavior(C.decimalNumberBehavior)
    let value = lhs.value.decimalNumberByDividingBy(divisor, withBehavior: C.decimalNumberBehavior)
    return Money(decimalNumber: value)
}

public func /<C: CurrencyType>(lhs: Money<C>, rhs: FloatLiteralType) -> Money<C> {
    let divisor = NSDecimalNumber(floatLiteral: rhs).decimalNumberByRoundingAccordingToBehavior(C.decimalNumberBehavior)
    let value = lhs.value.decimalNumberByDividingBy(divisor, withBehavior: C.decimalNumberBehavior)
    return Money(decimalNumber: value)
}

