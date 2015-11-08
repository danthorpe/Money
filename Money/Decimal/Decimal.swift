//
//  Decimal.swift
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
import ValueCoding

/**
 # Decimal
 A value type which implements `DecimalNumberType` using `NSDecimalNumber` internally.
 
 It is generic over the decimal number behavior type, which defines the rounding
 and scale rules for base 10 decimal arithmetic.
*/
public struct _Decimal<Behavior: DecimalNumberBehaviorType>: DecimalNumberType {

    public typealias DecimalNumberBehavior = Behavior

    /// Access the underlying decimal storage.
    /// - returns: the `NSDecimalNumber`
    public let storage: NSDecimalNumber
    
    /// Flag to indicate if the decimal number is less than zero
    public var isNegative: Bool {
        return storage.isNegative
    }

    /// The negative of Self.
    /// - returns: a `_Decimal<Behavior>`
    public var negative: _Decimal {
        return _Decimal(storage: storage.negateWithBehaviors(Behavior.decimalNumberBehaviors))
    }

    /// Text description.
    public var description: String {
        return "\(storage.description)"
    }

    /**
     Initialize a new value using the underlying decimal storage.

     - parameter storage: a `NSDecimalNumber` defaults to zero.
    */
    public init(storage: NSDecimalNumber = NSDecimalNumber.zero()) {
        self.storage = storage
    }

    /**
     Initialize a new value using a `FloatLiteralType`
     
     - parameter floatLiteral: a `FloatLiteralType` for the system, probably `Double`.
     */
    public init(floatLiteral value: FloatLiteralType) {
        self.init(storage: NSDecimalNumber(floatLiteral: value).decimalNumberByRoundingAccordingToBehavior(Behavior.decimalNumberBehaviors))
    }

    /**
     Initialize a new value using a `IntegerLiteralType`

     - parameter integerLiteral: a `IntegerLiteralType` for the system, probably `Int`.
     */
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

    /**
     Subtract a matching `_Decimal` from the receiver.
     
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func subtract(other: _Decimal) -> _Decimal {
        return _Decimal(storage: storage.subtract(other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     Add a matching `_Decimal` from the receiver.
     
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func add(other: _Decimal) -> _Decimal {
        return _Decimal(storage: storage.add(other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     Multiply a matching `_Decimal` from the receiver.
     
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func multiplyBy(other: _Decimal) -> _Decimal {
        return _Decimal(storage: storage.multiplyBy(other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     Divide a matching `_Decimal` from the receiver.
     
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func divideBy(other: _Decimal) -> _Decimal {
        return _Decimal(storage: storage.divideBy(other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     The remainder of dividing another `_Decimal` into the receiver.
     
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func remainder(other: _Decimal) -> _Decimal {
        return _Decimal(storage: storage.remainder(other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }
}

public func ==<B: DecimalNumberBehaviorType>(lhs: _Decimal<B>, rhs: _Decimal<B>) -> Bool {
    return lhs.storage == rhs.storage
}

public func <<B: DecimalNumberBehaviorType>(lhs: _Decimal<B>, rhs: _Decimal<B>) -> Bool {
    return lhs.storage < rhs.storage
}

/// `Decimal` with plain decimal number behavior
public typealias Decimal = _Decimal<DecimalNumberBehavior.Plain>

/// `BankersDecimal` with banking decimal number behavior
public typealias BankersDecimal = _Decimal<DecimalNumberBehavior.Bankers>

// MARK: - Value Coding

extension _Decimal: ValueCoding {
    public typealias Coder = _DecimalCoder<Behavior>
}

/**
 Coding class to support `_Decimal` `ValueCoding` conformance.
*/
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


