//
//  Decimal.swift
//  Money
//
//  Created by Daniel Thorpe on 29/10/2015.
//
//

import Foundation

// MARK: - NSDecimalNumber

public func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.isEqualToNumber(rhs)
}

public func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

/**
 # NSDecimalNumber Extension
 These is an extension on NSDecimalNumber to support `DecimalNumberType` and
 `Decimal`. 
 
 Note that NSDecimalNumber cannot conform to `DecimalNumberType` directly
 because it is a framework class which cannot be made final, and the protocol
 has functions which return Self.
*/
extension NSDecimalNumber: Comparable {
    
    public var isNegative: Bool {
        return NSDecimalNumber.zero().compare(self) == .OrderedDescending
    }

    public func negateWithBehaviors(behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let negativeOne = NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true)
        let result = decimalNumberByMultiplyingBy(negativeOne, withBehavior: behaviors)
        return result
    }
    
    @warn_unused_result
    public func subtract(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberBySubtracting(other, withBehavior: behaviors)
    }
    
    /**
     Add a matching `DecimalNumberType` to the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func add(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberByAdding(other, withBehavior: behaviors)
    }
    
    /**
     The remainder of dividing another `DecimalNumberType` into the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func remainder(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let roundingMode: NSRoundingMode = Int(isNegative) ^ Int(other.isNegative) ? .RoundUp : .RoundDown
        let roundingBehaviors = NSDecimalNumberHandler(roundingMode: roundingMode, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let quotient = divideBy(other, withBehaviors: roundingBehaviors)
        let toSubtract = quotient.multiplyBy(other, withBehaviors: behaviors)
        let result = subtract(toSubtract, withBehaviors: behaviors)
        
        if result.isNegative {
            return result.negateWithBehaviors(behaviors)
        }
        return result
    }
    
    /**
     Multiply a matching `DecimalNumberType` with the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func multiplyBy(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberByMultiplyingBy(other, withBehavior: behaviors)
    }
    
    /**
     Divide the receiver by a matching `DecimalNumberType`.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func divideBy(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberByDividingBy(other, withBehavior: behaviors)
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
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func subtract(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self

    /**
     Add a matching `DecimalNumberType` to the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func add(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self

    /**
     The remainder of dividing another `DecimalNumberType` into the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func remainder(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self

    /**
     Multiply a matching `DecimalNumberType` with the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func multiplyBy(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self

    /**
     Multiply another `DecimalNumberType` with the receiver. The other 
     `DecimalNumberType` must have the same underlying `DecimalStorageType` as
     this `DecimalNumberType`.

     - parameter other: another `DecimalNumberType` value of different type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: a different `DecimalNumberType` value.
     */
    @warn_unused_result
    func multiplyBy<Other: DecimalNumberType where Other.DecimalStorageType == DecimalStorageType>(_: Other, withBehaviors: NSDecimalNumberBehaviors?) -> Other

    /**
     Divide the receiver by a matching `DecimalNumberType`.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func divideBy(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self
}

extension DecimalNumberType where DecimalStorageType == NSDecimalNumber {

    @warn_unused_result
    public func multiplyBy<Other: DecimalNumberType where Other.DecimalStorageType == NSDecimalNumber>(other: Other, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> Other {
        return Other(storage: storage.multiplyBy(other.storage, withBehaviors: behaviors))
    }

    @warn_unused_result
    public func divideBy<Other: DecimalNumberType where Other.DecimalStorageType == NSDecimalNumber>(other: Other, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> Other {
        return Other(storage: storage.divideBy(other.storage, withBehaviors: behaviors))
    }
}

extension DecimalNumberType where Self.IntegerLiteralType == Int {

    public var reciprocal: Self {
        return Self(integerLiteral: 1).divideBy(self, withBehaviors: DecimalNumberBehavior.decimalNumberBehaviors)
    }
}


// MARK: - Subtraction

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.subtract(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
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

// MARK: - Remainder

@warn_unused_result
public func %<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.remainder(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
}

// MARK: - Addition

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.add(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
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
    return lhs.multiplyBy(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
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
    T.DecimalStorageType == NSDecimalNumber,
    V.DecimalStorageType == NSDecimalNumber>(lhs: T, rhs: V) -> V {
        return lhs.multiplyBy(rhs, withBehaviors: V.DecimalNumberBehavior.decimalNumberBehaviors)
}

// MARK: - Division

@warn_unused_result
public func /<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.divideBy(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
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
    T.DecimalStorageType == NSDecimalNumber,
    V.DecimalStorageType == NSDecimalNumber>(lhs: T, rhs: V) -> V {
        return lhs.divideBy(rhs, withBehaviors: V.DecimalNumberBehavior.decimalNumberBehaviors)
}

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

// MARK: - Conformance

public protocol DecimalNumberBehaviorType {

    /// Specify the decimal number (i.e. rounding, scale etc) for base 10 calculations
    static var decimalNumberBehaviors: NSDecimalNumberBehaviors? { get }
}

public struct DecimalNumberBehavior {

    private static func behaviorWithRoundingMode(mode: NSRoundingMode) -> NSDecimalNumberBehaviors? {
        return NSDecimalNumberHandler(roundingMode: mode, scale: 38, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
    }

    public struct Plain: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundPlain)
    }

    public struct RoundDown: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundDown)
    }

    public struct RoundUp: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundUp)
    }

    public struct Bankers: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundBankers)
    }
}

/// Standard `Decimal` with plain decimal number behavior
public typealias Decimal = _Decimal<DecimalNumberBehavior.Plain>
public typealias BankersDecimal = _Decimal<DecimalNumberBehavior.Bankers>



