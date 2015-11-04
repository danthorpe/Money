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

    /// Access the underlying decimal
    var decimal: _Decimal<Currency> { get }

    init(_: _Decimal<Currency>)
}

/**
 # Money
 Money is a value type, which is generic over the currency type.
 
 To work in whatever the local currency is, use `Local`.

*/
public struct _Money<C: CurrencyType>: MoneyType {
    
    public typealias DecimalNumberBehavior = C
    public typealias Currency = C

    public let decimal: _Decimal<C>

    public var storage: NSDecimalNumber {
        return decimal.storage
    }

    public var isNegative: Bool {
        return decimal.isNegative
    }
    
    public var negative: _Money {
        return _Money(decimal.negative)
    }
    
    public init(_ value: _Decimal<C> = _Decimal<C>()) {
        decimal = value
    }

    public init(storage: NSDecimalNumber) {
        decimal = _Decimal<DecimalNumberBehavior>(storage: storage)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        decimal = _Decimal<DecimalNumberBehavior>(integerLiteral: value)
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        decimal = _Decimal<DecimalNumberBehavior>(floatLiteral: value)
    }
    
    @warn_unused_result
    public func subtract(other: _Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Money<C> {
        return _Money(decimal.subtract(other.decimal, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func add(other: _Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Money<C> {
        return _Money(decimal.add(other.decimal, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func remainder(other: _Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Money<C> {
        return _Money(decimal.remainder(other.decimal, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func multiplyBy(other: _Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Money<C> {
        return _Money(decimal.multiplyBy(other.decimal, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func divideBy(other: _Money<C>, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Money<C> {
        return _Money(decimal.divideBy(other.decimal, withBehaviors: behaviors))
    }
}

// MARK: - Equality

public func ==<C: CurrencyType>(lhs: _Money<C>, rhs: _Money<C>) -> Bool {
    return lhs.decimal == rhs.decimal
}

// MARK: - Comparable

public func <<C: CurrencyType>(lhs: _Money<C>, rhs: _Money<C>) -> Bool {
    return lhs.decimal < rhs.decimal
}

// MARK: - Consumption Types

public typealias Money = _Money<Currency.Local>

// MARK: - CustomStringConvertible

extension _Money: CustomStringConvertible {

    /**
     Returns the result of the `formatted` function using
     NSNumberFormatterStyle.CurrencyStyle.
    */
    public var description: String {
        return formatted(.CurrencyStyle)
    }

    /**
     ### Localized Formatted String
     This function will format the Money type into a string suitable
     for the current localization. It accepts an parameter for the 
     style `NSNumberFormatterStyle`. Note that iOS 9 and OS X 10.11
     added new styles which are relevant for currency.
     
     These are `.CurrencyISOCodeStyle`, `.CurrencyPluralStyle`, and 
     `.CurrencyAccountingStyle`.
    */
    public func formatted(style: NSNumberFormatterStyle) -> String {
        return C.formatter.formattedStringWithStyle(style)(decimal)
    }
}
