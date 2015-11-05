//
//  Decimal.swift
//  Money
//
//  Created by Daniel Thorpe on 29/10/2015.
//
//

import Foundation
import ValueCoding

/**
 # Decimal
 A value type which implements `DecimalNumberType` using `NSDecimalNumber` internally.
 
 It is generic over the decimal number behavior type, which defines the rounding
 and scale rules for base 10 decimal arithmetic.
*/
public struct _Decimal<Behavior: DecimalNumberBehaviorType>: DecimalNumberType {
    public typealias DecimalNumberBehavior = Behavior
    
    public let storage: NSDecimalNumber
    
    /// Flag to indicate if the decimal number is less than zero
    public var isNegative: Bool {
        return storage.isNegative
    }
    
    public var negative: _Decimal {
        return _Decimal(storage: storage.negateWithBehaviors(Behavior.decimalNumberBehaviors))
    }

    public var description: String {
        return "\(storage.description)"
    }

    public init(storage: NSDecimalNumber = NSDecimalNumber.zero()) {
        self.storage = storage
    }

    public init(floatLiteral value: FloatLiteralType) {
        self.init(storage: NSDecimalNumber(floatLiteral: value).decimalNumberByRoundingAccordingToBehavior(Behavior.decimalNumberBehaviors))
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        switch value {
        case 0:
            self.init(storage: NSDecimalNumber.zero())
        case 1:
            self.init(storage: NSDecimalNumber.one())
        default:
            self.init(storage: NSDecimalNumber(integerLiteral: value).decimalNumberByRoundingAccordingToBehavior(Behavior.decimalNumberBehaviors))
        }
    }

    @warn_unused_result
    public func subtract(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(storage: storage.subtract(other.storage, withBehaviors: behaviors))
    }

    @warn_unused_result
    public func add(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(storage: storage.add(other.storage, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func remainder(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(storage: storage.remainder(other.storage, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func multiplyBy(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(storage: storage.multiplyBy(other.storage, withBehaviors: behaviors))
    }

    @warn_unused_result
    public func divideBy(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(storage: storage.divideBy(other.storage, withBehaviors: behaviors))
    }
}

public func ==<B: DecimalNumberBehaviorType>(lhs: _Decimal<B>, rhs: _Decimal<B>) -> Bool {
    return lhs.storage == rhs.storage
}

public func <<B: DecimalNumberBehaviorType>(lhs: _Decimal<B>, rhs: _Decimal<B>) -> Bool {
    return lhs.storage < rhs.storage
}

/// Standard `Decimal` with plain decimal number behavior
public typealias Decimal = _Decimal<DecimalNumberBehavior.Plain>
public typealias BankersDecimal = _Decimal<DecimalNumberBehavior.Bankers>

// MARK: - Value Coding

extension _Decimal: ValueCoding {
    public typealias Coder = _DecimalCoder<Behavior>
}

public final class _DecimalCoder<Behavior: DecimalNumberBehaviorType>: NSObject, NSCoding, CodingType {

    public let value: _Decimal<Behavior>

    public required init(_ v: _Decimal<Behavior>) {
        value = v
    }

    public init?(coder aDecoder: NSCoder) {
        let storage = aDecoder.decodeObjectForKey("storage") as! NSDecimalNumber
        value = _Decimal<Behavior>(storage: storage)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.storage, forKey: "storage")
    }
}



// TODO: - Move these into DecimalNumberType

extension NSNumberFormatter {

    func stringFromDecimal<B: DecimalNumberBehaviorType>(decimal: _Decimal<B>) -> String? {
        return stringFromNumber(decimal.storage)
    }

    func formattedStringWithStyle<B: DecimalNumberBehaviorType>(style: NSNumberFormatterStyle) -> _Decimal<B> -> String {
        let currentStyle = numberStyle
        numberStyle = style
        let result: _Decimal<B> -> String = { decimal in
            return self.stringFromDecimal(decimal)!
        }
        numberStyle = currentStyle
        return result
    }
}


