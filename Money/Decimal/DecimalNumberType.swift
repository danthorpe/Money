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
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundPlain)
    }

    /// Round down mode
    public struct RoundDown: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundDown)
    }

    /// Round up mode
    public struct RoundUp: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundUp)
    }

    /// Bankers rounding mode, see `NSRoundingMode.RoundBankers` for info.
    public struct Bankers: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundBankers)
    }

    private static func behaviorWithRoundingMode(mode: NSRoundingMode, scale: Int16 = 38) -> NSDecimalNumberBehaviors {
        return NSDecimalNumberHandler(roundingMode: mode, scale: 38, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
    }
}


/**
 # DecimalNumberType
 A protocol which defines the necessary interface to support decimal number
 calculations and operators.
 */
public protocol DecimalNumberType: SignedNumberType, IntegerLiteralConvertible, FloatLiteralConvertible, CustomStringConvertible {

    typealias DecimalStorageType
    typealias DecimalNumberBehavior: DecimalNumberBehaviorType

    /// Access the underlying storage
    var storage: DecimalStorageType { get }

    /// Flag to indicate if the decimal number is less than zero
    var isNegative: Bool { get }

    /**
     Negates the receiver, equivalent to multiplying it by -1
     - returns: another instance of this type.
     */
    var negative: Self { get }

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
    @warn_unused_result
    func subtract(_: Self) -> Self

    /**
     Add a matching `DecimalNumberType` to the receiver.
     
     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    @warn_unused_result
    func add(_: Self) -> Self

    /**
     Multiply a matching `DecimalNumberType` with the receiver.
     
     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    @warn_unused_result
    func multiplyBy(_: Self) -> Self

    /**
     Multiply another `DecimalNumberType` with the receiver. The other
     `DecimalNumberType` must have the same underlying `DecimalStorageType` as
     this `DecimalNumberType`.

     - parameter other: another `DecimalNumberType` value of different type.
     - returns: a different `DecimalNumberType` value.
     */
    @warn_unused_result
    func multiplyBy<Other: DecimalNumberType where Other.DecimalStorageType == DecimalStorageType>(_: Other) -> Other

    /**
     Divide the receiver by a matching `DecimalNumberType`.
     
     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    @warn_unused_result
    func divideBy(_: Self) -> Self

    /**
     Divide the receiver by another `DecimalNumberType`.  The other
     `DecimalNumberType` must have the same underlying `DecimalStorageType` as
     this `DecimalNumberType`.

     - parameter other: another `DecimalNumberType` value of different type.
     - returns: another instance of this type.
     */
    @warn_unused_result
    func divideBy<Other: DecimalNumberType where Other.DecimalStorageType == DecimalStorageType>(_: Other) -> Other

    /**
     The remainder of dividing another `DecimalNumberType` into the receiver.
     
     - parameter other: another instance of this type.
     - returns: another instance of this type.
     */
    @warn_unused_result
    func remainder(_: Self) -> Self
}

public extension DecimalNumberType where DecimalStorageType == NSDecimalNumber {

    @warn_unused_result
    func multiplyBy<Other: DecimalNumberType where Other.DecimalStorageType == NSDecimalNumber>(other: Other) -> Other {
        return Other(storage: storage.multiplyBy(other.storage, withBehaviors: Other.DecimalNumberBehavior.decimalNumberBehaviors) )
    }

    @warn_unused_result
    func divideBy<Other: DecimalNumberType where Other.DecimalStorageType == NSDecimalNumber>(other: Other) -> Other {
        return Other(storage: storage.divideBy(other.storage, withBehaviors: Other.DecimalNumberBehavior.decimalNumberBehaviors))
    }
}

extension DecimalNumberType where Self.IntegerLiteralType == Int {

    /// Get the reciprocal of the receiver.
    public var reciprocal: Self {
        return Self(integerLiteral: 1).divideBy(self)
    }
}

// MARK: - Operators

// MARK: - Subtraction

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.subtract(rhs)
}

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs - T(integerLiteral: rhs)
}

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return T(integerLiteral: lhs) - rhs
}

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs - T(floatLiteral: rhs)
}

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return T(floatLiteral: lhs) - rhs
}

// MARK: - Addition

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.add(rhs)
}

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs + T(integerLiteral: rhs)
}

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return T(integerLiteral: lhs) + rhs
}

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs + T(floatLiteral: rhs)
}

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return T(floatLiteral: lhs) + rhs
}

// MARK: - Multiplication

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.multiplyBy(rhs)
}

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs * T(integerLiteral: rhs)
}

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs * T(floatLiteral: rhs)
}

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return rhs * lhs
}

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return rhs * lhs
}

@warn_unused_result
public func *<T, V where
    T: DecimalNumberType,
    V: DecimalNumberType,
    T.DecimalStorageType == V.DecimalStorageType>(lhs: T, rhs: V) -> V {
        return lhs.multiplyBy(rhs)
}

// MARK: - Division

@warn_unused_result
public func /<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.divideBy(rhs)
}

@warn_unused_result
public func /<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs / T(integerLiteral: rhs)
}

@warn_unused_result
public func /<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs / T(floatLiteral: rhs)
}

@warn_unused_result
public func /<T, V where
    T: DecimalNumberType,
    V: DecimalNumberType,
    T.DecimalStorageType == V.DecimalStorageType>(lhs: T, rhs: V) -> V {
        return lhs.divideBy(rhs)
}

// MARK: - Remainder

@warn_unused_result
public func %<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.remainder(rhs)
}



