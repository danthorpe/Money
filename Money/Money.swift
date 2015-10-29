//
//  Money.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

/**
 # MoneyType
 `MoneyType` is a protocol which refines `DecimalNumberType`. It
 adds a generic type for the currency.
 
 Some functionality can be be provided via general implementations.
 */
public protocol MoneyType: DecimalNumberType {
    typealias Currency: CurrencyType
}


/**
 # Money
 Money is a value type, which is generic over the currency type.
 
 To work in whatever the local currency is, use `Local`.

*/
public struct Money<C: CurrencyType>: MoneyType {
    public typealias DecimalNumberBehavior = C
    public typealias Currency = C

    private let decimal: Decimal<C>

    public var isNegative: Bool {
        return decimal.isNegative
    }
    
    
    init(_ value: Decimal<C> = Decimal<C>()) {
        decimal = value
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        decimal = Decimal<DecimalNumberBehavior>(integerLiteral: value)
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        decimal = Decimal<DecimalNumberBehavior>(floatLiteral: value)
    }
    
    @warn_unused_result
    public func negateWithBehaviors(behaviors: NSDecimalNumberBehaviors?) -> Money<C> {
        return Money(decimal.negateWithBehaviors(behaviors))
    }
    
    @warn_unused_result
    public func subtract(other: Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> Money<C> {
        return Money(decimal.subtract(other.decimal, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func add(other: Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> Money<C> {
        return Money(decimal.add(other.decimal, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func remainder(other: Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> Money<C> {
        return Money(decimal.remainder(other.decimal, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func multiplyBy(other: Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> Money<C> {
        return Money(decimal.multiplyBy(other.decimal, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func divideBy(other: Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> Money<C> {
        return Money(decimal.divideBy(other.decimal, withBehaviors: behaviors))
    }
}

// MARK: - Equality

public func ==<C: CurrencyType>(lhs: Money<C>, rhs: Money<C>) -> Bool {
    return lhs.decimal == rhs.decimal
}

// MARK: - Comparable

public func <<C: CurrencyType>(lhs: Money<C>, rhs: Money<C>) -> Bool {
    return lhs.decimal < rhs.decimal
}

