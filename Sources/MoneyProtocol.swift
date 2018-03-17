//
// Money
// File created on 15/09/2017.
// 	
// Copyright (c) 2015-2017 Daniel Thorpe
// 
// Money is licensed under the MIT License. Read the full license at 
// https://github.com/danthorpe/Money/blob/master/LICENSE
//

import Foundation

public protocol MoneyProtocol: SignedNumeric, ExpressibleByFloatLiteral, CustomStringConvertible {

    var decimal: Decimal { get }

    var currency: CurrencyProtocol { get }

    init(decimal: Decimal)

}

public extension MoneyProtocol {

    var amount: NSDecimalNumber {
        return (decimal as NSDecimalNumber)
    }
    
    var integerValue: Int {
        return Int(amount.doubleValue)
    }

    var floatValue: Double {
        return amount.doubleValue
    }

    var minorUnits: Int {
        return Int((decimal.multiplying(byPowersOf10: Int16(currency.scale)) as NSDecimalNumber).doubleValue)
    }

    var description: String {
        return formatted(withStyle: .currency, forLocaleId: Locale.current.identifier)
    }

    func formatted(withStyle style: NumberFormatter.Style = .currency, forLocaleId localeId: String = Locale.current.identifier) -> String {
        return currency.numberFormatter(withStyle: style, forLocaleId: localeId).string(from: decimal as NSDecimalNumber) ?? decimal.description
    }
}

extension MoneyProtocol {

    public static func +(lhs: Self, rhs: Self) -> Self {
        var (lhs, rhs) = (lhs.decimal, rhs.decimal)
        var result = Decimal()
        NSDecimalAdd(&result, &lhs, &rhs, .bankers)
        return Self(decimal: result)
    }

    public static func -(lhs: Self, rhs: Self) -> Self {
        var (lhs, rhs) = (lhs.decimal, rhs.decimal)
        var result = Decimal()
        NSDecimalSubtract(&result, &lhs, &rhs, .bankers)
        return Self(decimal: result)
    }


    public static func *(lhs: Self, rhs: Self) -> Self {
        var (lhs, rhs) = (lhs.decimal, rhs.decimal)
        var result = Decimal()
        NSDecimalMultiply(&result, &lhs, &rhs, .bankers)
        return Self(decimal: result)
    }


    public static func /(lhs: Self, rhs: Self) -> Self {
        var (lhs, rhs) = (lhs.decimal, rhs.decimal)
        var result = Decimal()
        NSDecimalDivide(&result, &lhs, &rhs, .bankers)
        return Self(decimal: result)
    }
}

extension MoneyProtocol where IntegerLiteralType == Decimal.IntegerLiteralType {

    public static func +(lhs: Self, rhs: Self.IntegerLiteralType) -> Self {
        return Self(decimal: lhs.decimal + Decimal(integerLiteral: rhs))
    }

    public static func +(lhs: Self.IntegerLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(integerLiteral: lhs) + rhs.decimal)
    }


    public static func -(lhs: Self, rhs: Self.IntegerLiteralType) -> Self {
        return Self(decimal: lhs.decimal - Decimal(integerLiteral: rhs))
    }

    public static func -(lhs: Self.IntegerLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(integerLiteral: lhs) - rhs.decimal)
    }

    public static func *(lhs: Self, rhs: Self.IntegerLiteralType) -> Self {
        return Self(decimal: lhs.decimal * Decimal(integerLiteral: rhs))
    }

    public static func *(lhs: Self.IntegerLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(integerLiteral: lhs) * rhs.decimal)
    }

    public static func /(lhs: Self, rhs: Self.IntegerLiteralType) -> Self {
        return Self(decimal: lhs.decimal / Decimal(integerLiteral: rhs))
    }

    public static func /(lhs: Self.IntegerLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(integerLiteral: lhs) / rhs.decimal)
    }
}

extension MoneyProtocol where FloatLiteralType == Decimal.FloatLiteralType {

    public static func +(lhs: Self, rhs: Self.FloatLiteralType) -> Self {
        return Self(decimal: lhs.decimal + Decimal(floatLiteral: rhs))
    }

    public static func +(lhs: Self.FloatLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(floatLiteral: lhs) + rhs.decimal)
    }

    public static func -(lhs: Self, rhs: Self.FloatLiteralType) -> Self {
        return Self(decimal: lhs.decimal - Decimal(floatLiteral: rhs))
    }

    public static func -(lhs: Self.FloatLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(floatLiteral: lhs) - rhs.decimal)
    }

    public static func *(lhs: Self, rhs: Self.FloatLiteralType) -> Self {
        return Self(decimal: lhs.decimal * Decimal(floatLiteral: rhs))
    }

    public static func *(lhs: Self.FloatLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(floatLiteral: lhs) * rhs.decimal)
    }

    public static func /(lhs: Self, rhs: Self.FloatLiteralType) -> Self {
        return Self(decimal: lhs.decimal / Decimal(floatLiteral: rhs))
    }

    public static func /(lhs: Self.FloatLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(floatLiteral: lhs) / rhs.decimal)
    }
}

extension MoneyProtocol {
	
	public static func +(lhs: Self, rhs: Decimal) -> Self {
		return Self(decimal: lhs.decimal + rhs)
	}
	
	public static func +(lhs: Decimal, rhs: Self) -> Self {
		return Self(decimal: lhs + rhs.decimal)
	}
	
	public static func -(lhs: Self, rhs: Decimal) -> Self {
		return Self(decimal: lhs.decimal - rhs)
	}
	
	public static func -(lhs: Decimal, rhs: Self) -> Self {
		return Self(decimal: lhs - rhs.decimal)
	}
	
	public static func *(lhs: Self, rhs: Decimal) -> Self {
		return Self(decimal: lhs.decimal * rhs)
	}
	
	public static func *(lhs: Decimal, rhs: Self) -> Self {
		return Self(decimal: lhs * rhs.decimal)
	}
	
	public static func /(lhs: Self, rhs: Decimal) -> Self {
		return Self(decimal: lhs.decimal / rhs)
	}
	
	public static func /(lhs: Decimal, rhs: Self) -> Self {
		return Self(decimal: lhs / rhs.decimal)
	}
}

public extension MoneyProtocol {

    func distance(to other: Self) -> Self {
        return self - other
    }

    func advanced(by other: Self) -> Self {
        return self + other
    }
}

public extension MoneyProtocol {

    init(_ value: Int8) {
        self.init(decimal: Decimal(value))
    }

    init(_ value: Int16) {
        self.init(decimal: Decimal(value))
    }

    init(_ value: Int32) {
        self.init(decimal: Decimal(value))
    }

    init(_ value: Int64) {
        self.init(decimal: Decimal(value))
    }

    init(_ value: UInt8) {
        self.init(decimal: Decimal(value))
    }

    init(_ value: UInt16) {
        self.init(decimal: Decimal(value))
    }

    init(_ value: UInt32) {
        self.init(decimal: Decimal(value))
    }

    init(_ value: UInt64) {
        self.init(decimal: Decimal(value))
    }

    init(_ value: Int) {
        self.init(decimal: Decimal(value))
    }

    init(_ value: UInt) {
        self.init(decimal: Decimal(value))
    }

}




