//
// Money, https://github.com/danthorpe/Money
// Created by Dan Thorpe, @danthorpe
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

    /**
     Initialize a new value using the underlying decimal storage.

     - parameter storage: a `NSDecimalNumber` defaults to zero.
    */
    public init(storage: NSDecimalNumber = NSDecimalNumber.zero) {
        self.storage = storage
    }
}

// MARK: - Equality

public func ==<B: DecimalNumberBehaviorType>(lhs: _Decimal<B>, rhs: _Decimal<B>) -> Bool {
    return lhs.storage == rhs.storage
}

// MARK: - Comparable

public func <<B: DecimalNumberBehaviorType>(lhs: _Decimal<B>, rhs: _Decimal<B>) -> Bool {
    return lhs.storage < rhs.storage
}

/// `Decimal` with plain decimal number behavior
public typealias PlainDecimal = _Decimal<DecimalNumberBehavior.Plain>

/// `BankersDecimal` with banking decimal number behavior
public typealias BankersDecimal = _Decimal<DecimalNumberBehavior.Bankers>

// MARK: - Value Coding

extension _Decimal: ValueCoding {
    public typealias Coder = _DecimalCoder<Behavior>
}

/**
 Coding class to support `_Decimal` `ValueCoding` conformance.
*/
public final class _DecimalCoder<Behavior: DecimalNumberBehaviorType>: NSObject, NSCoding, CodingProtocol {

    public let value: _Decimal<Behavior>

    public required init(_ v: _Decimal<Behavior>) {
        value = v
    }

    public init?(coder aDecoder: NSCoder) {
        let storage = aDecoder.decodeObject(forKey: "storage") as! NSDecimalNumber
        value = _Decimal<Behavior>(storage: storage)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(value.storage, forKey: "storage")
    }
}


