//
//  DecimalNumberType.swift
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

/**

 # DecimalNumberBehaviorType
 
 Defines the decimal number behavior, i.e. `NSDecimalNumberBehaviors`
 of the type.

 */
public protocol DecimalNumberBehaviorType {

    /// Specify the decimal number (i.e. rounding, scale etc) for base 10 calculations
    static var decimalNumberBehaviors: NSDecimalNumberBehaviors { get }
}

/**

 # DecimalNumberBehavior
 
 This is a name space of types which conform to `DecimalNumberBehaviorType`
 with common rounding modes. All have maximum precision, of 38 significant
 digits.
*/
public struct DecimalNumberBehavior {

    /// Plain rounding mode
    public struct Plain: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(mode: .plain)
    }

    /// Round down mode
    public struct RoundDown: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(mode: .down)
    }

    /// Round up mode
    public struct RoundUp: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(mode: .up)
    }

    /// Bankers rounding mode, see `NSRoundingMode.RoundBankers` for info.
    public struct Bankers: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(mode: .bankers)
    }

    private static func behaviorWithRoundingMode(mode: NSDecimalNumber.RoundingMode, scale: Int16 = 38) -> NSDecimalNumberBehaviors {
        return NSDecimalNumberHandler(roundingMode: mode, scale: 38, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
    }
}

/**
 
 # DecimalNumberType
 
 A protocol which defines the necessary interface to support decimal number
 calculations and operators.
 */
public protocol DecimalNumberType: Hashable, SignedNumber, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, CustomStringConvertible {

    associatedtype DecimalStorageType
    associatedtype DecimalNumberBehavior: DecimalNumberBehaviorType

    /// Access the underlying storage
    var storage: DecimalStorageType { get }

    /// Flag to indicate if the decimal number is less than zero
    var isNegative: Bool { get }

    /**
     Negates the receiver, equivalent to multiplying it by -1
     - returns: another instance of this type.
     */
    var negative: Self { get }

    /// Access an integer value representation
    var intValue: Swift.IntegerLiteralType { get }

    /// Access a float value representation
    var floatValue: FloatLiteralType { get }

    /**
     Initialize a new `DecimalNumberType` with the underlying storage.
     This is necessary in order to convert between different decimal number
     types.
     
     - parameter storage: the underlying decimal storage type
     e.g. NSDecimalNumber or NSDecimal
     */
    init(storage: DecimalStorageType)

    /**
     Subtract a matching `DecimalNumberType` from the receiver.
     
     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func subtract(_: Self) -> Self

    /**
     Add a matching `DecimalNumberType` to the receiver.
     
     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func add(_: Self) -> Self

    /**
     Multiply the receive by 10^n

     - parameter n: an `Int` for the 10 power index
     - returns: another instance of this type.
     */
    func multiply(byPowerOf10: Int) -> Self

    /**
     Multiply a matching `DecimalNumberType` with the receiver.
     
     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func multiply(by: Self) -> Self

    /**
     Multiply another `DecimalNumberType` with the receiver. The other
     `DecimalNumberType` must have the same underlying `DecimalStorageType` as
     this `DecimalNumberType`.

     - parameter other: another `DecimalNumberType` value of different type.
     - returns: a different `DecimalNumberType` value.
     */
    func multiply<Other: DecimalNumberType>(by: Other) -> Other where Other.DecimalStorageType == DecimalStorageType

    /**
     Divide the receiver by a matching `DecimalNumberType`.
     
     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func divide(by: Self) -> Self

    /**
     Divide the receiver by another `DecimalNumberType`.  The other
     `DecimalNumberType` must have the same underlying `DecimalStorageType` as
     this `DecimalNumberType`.

     - parameter other: another `DecimalNumberType` value of different type.
     - returns: another instance of this type.
     */
    func divide<Other: DecimalNumberType>(by: Other) -> Other where Other.DecimalStorageType == DecimalStorageType

    /**
     The remainder of dividing another `DecimalNumberType` into the receiver.
     
     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func remainder(of: Self) -> Self
}

// MARK: - Extensions

/**
 Extensions on `DecimalNumberType` where the underlying storage type
 is `NSDecimalNumber`.
 */
public extension DecimalNumberType where DecimalStorageType == NSDecimalNumber {

    /// Flag to indicate if the decimal number is less than zero
    var isNegative: Bool {
        return storage.isNegative
    }

    /// The negative of Self.
    /// - returns: a `_Decimal<Behavior>`
    var negative: Self {
        return Self(storage: storage.negate(withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /// Access an integer value representation
    var intValue: Int {
        return storage.intValue
    }

    /// Access a float value representation
    var floatValue: Double {
        return storage.doubleValue
    }

    /// Text description.
    var description: String {
        return "\(storage.description)"
    }

    /// Hash value
    var hashValue: Int {
        return storage.hashValue
    }

    /// Initialize a new decimal with an `Int`.
    /// - parameter value: an `Int`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: Int) {
        switch value {
        case 0:
            self.init(storage: NSDecimalNumber.zero)
        case 1:
            self.init(storage: NSDecimalNumber.one)
        default:
            self.init(storage: NSDecimalNumber(integerLiteral: value).rounding(accordingToBehavior: DecimalNumberBehavior.decimalNumberBehaviors))
        }
    }

    /// Initialize a new decimal with an `UInt8`.
    /// - parameter value: an `UInt8`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: UInt8) {
        self.init(Int(value))
    }

    /// Initialize a new decimal with an `Int8`.
    /// - parameter value: an `Int8`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: Int8) {
        self.init(Int(value))
    }

    /// Initialize a new decimal with an `UInt16`.
    /// - parameter value: an `UInt16`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: UInt16) {
        self.init(Int(value))
    }

    /// Initialize a new decimal with an `Int16`.
    /// - parameter value: an `Int16`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: Int16) {
        self.init(Int(value))
    }

    /// Initialize a new decimal with an `UInt32`.
    /// - parameter value: an `UInt32`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: UInt32) {
        self.init(Int(value))
    }

    /// Initialize a new decimal with an `Int32`.
    /// - parameter value: an `Int32`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: Int32) {
        self.init(Int(value))
    }

    /// Initialize a new decimal with an `UInt64`.
    /// - parameter value: an `UInt64`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: UInt64) {
        self.init(Int(value))
    }

    /// Initialize a new decimal with an `Int64`.
    /// - parameter value: an `Int64`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: Int64) {
        self.init(Int(value))
    }

    /**
     Initialize a new value using a `IntegerLiteralType`

     - parameter integerLiteral: a `IntegerLiteralType` for the system, probably `Int`.
     */
    init(integerLiteral value: Swift.IntegerLiteralType) {
        self.init(value)
    }

    /// Initialize a new decimal with an `Double`.
    /// - parameter value: an `Double`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: Double) {
        self.init(storage: NSDecimalNumber(floatLiteral: value).rounding(accordingToBehavior: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /// Initialize a new decimal with a `Float`.
    /// - parameter value: an `Float`.
    /// - returns: an initialized `DecimalNumberType`.
    init(_ value: Float) {
        self.init(Double(value))
    }

    /**
     Initialize a new value using a `FloatLiteralType`

     - parameter floatLiteral: a `FloatLiteralType` for the system, probably `Double`.
     */
    init(floatLiteral value: Swift.FloatLiteralType) {
        self.init(value)
    }

    /**
     Subtract a matching `DecimalNumberType` from the receiver.

     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func subtract(_ other: Self) -> Self {
        return Self(storage: storage.subtract(other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     Add a matching `DecimalNumberType` from the receiver.

     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func add(_ other: Self) -> Self {
        return Self(storage: storage.add(other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     Multiply the receive by 10^n

     - parameter n: an `Int` for the 10 power index
     - returns: another instance of this type.
     */
    func multiply(byPowerOf10 index: Int) -> Self {
        return Self(storage: storage.multiply(byPowerOf10: index, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     Multiply a matching `DecimalNumberType` with the receiver.

     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func multiply(by other: Self) -> Self {
        return Self(storage: storage.multiply(by: other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     Multiply a different `DecimalNumberType` which also has `NSDecimalNumber`
     as the storage type with the receiver.

     - parameter other: another `DecimalNumberType` with `NSDecimalNumber` storage.
     - returns: another instance of this type.
     */
    func multiply<Other: DecimalNumberType>(by other: Other) -> Other where Other.DecimalStorageType == NSDecimalNumber {
        return Other(storage: storage.multiply(by: other.storage, withBehaviors: Other.DecimalNumberBehavior.decimalNumberBehaviors) )
    }

    /**
     Divide the receiver by another instance of this type.

     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func divide(by other: Self) -> Self {
        return Self(storage: storage.divide(by: other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     Divide the receiver by a different `DecimalNumberType` which also has `NSDecimalNumber`
     as the storage type.

     - parameter other: another `DecimalNumberType` with `NSDecimalNumber` storage.
     - returns: another instance of this type.
     */
    func divide<Other: DecimalNumberType>(by other: Other) -> Other where Other.DecimalStorageType == NSDecimalNumber {
        return Other(storage: storage.divide(by: other.storage, withBehaviors: Other.DecimalNumberBehavior.decimalNumberBehaviors))
    }

    /**
     The remainder of dividing another instance of this type into the receiver.

     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    func remainder(of other: Self) -> Self {
        return Self(storage: storage.remainder(other: other.storage, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors))
    }
}

extension DecimalNumberType where Self.IntegerLiteralType == Int {

    /// Get the reciprocal of the receiver.
    public var reciprocal: Self {
        return Self(integerLiteral: 1).divide(by: self)
    }
}


// MARK: - Operators

// MARK: - Subtraction

public func -<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.subtract(rhs)
}

public func -<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs - T(integerLiteral: rhs)
}

public func -<T: DecimalNumberType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return T(integerLiteral: lhs) - rhs
}

public func -<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs - T(floatLiteral: rhs)
}

public func -<T: DecimalNumberType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return T(floatLiteral: lhs) - rhs
}

// MARK: - Addition

public func +<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.add(rhs)
}

public func +<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs + T(integerLiteral: rhs)
}

public func +<T: DecimalNumberType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return T(integerLiteral: lhs) + rhs
}

public func +<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs + T(floatLiteral: rhs)
}

public func +<T: DecimalNumberType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return T(floatLiteral: lhs) + rhs
}

// MARK: - Multiplication

public func *<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.multiply(by: rhs)
}

public func *<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs * T(integerLiteral: rhs)
}

public func *<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs * T(floatLiteral: rhs)
}

public func *<T: DecimalNumberType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return rhs * lhs
}

public func *<T: DecimalNumberType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return rhs * lhs
}

public func *<T, V>(lhs: T, rhs: V) -> V where
    T: DecimalNumberType,
    V: DecimalNumberType,
    T.DecimalStorageType == V.DecimalStorageType {
        return lhs.multiply(by: rhs)
}

// MARK: - Division

public func /<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.divide(by: rhs)
}

public func /<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs / T(integerLiteral: rhs)
}

public func /<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs / T(floatLiteral: rhs)
}

public func /<T, V>(lhs: T, rhs: V) -> V where
    T: DecimalNumberType,
    V: DecimalNumberType,
    T.DecimalStorageType == V.DecimalStorageType {
        return lhs.divide(by: rhs)
}

// MARK: - Remainder

public func %<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.remainder(of: rhs)
}



