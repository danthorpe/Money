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

    public init(decimalNumber: NSDecimalNumber = NSDecimalNumber.zero()) {
        self.value = decimalNumber
    }
}

public typealias Cash = Money<LocalCurrency>

// MARK: - Literal Convertibles

extension Money: FloatLiteralConvertible {

    public init(floatLiteral value: FloatLiteralType) {
        self.value = NSDecimalNumber(floatLiteral: value).decimalNumberByRoundingAccordingToBehavior(C.decimalNumberBehavior)
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
            self.value = NSDecimalNumber(integerLiteral: value).decimalNumberByRoundingAccordingToBehavior(C.decimalNumberBehavior)
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
    return Money(decimalNumber: x.value.decimalNumberByMultiplyingBy(NSDecimalNumber.minusOnewithBehavior(behavior), withBehavior: behavior))
}



