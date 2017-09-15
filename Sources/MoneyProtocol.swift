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

protocol MoneyProtocol: SignedNumeric, ExpressibleByFloatLiteral {

    var decimal: Decimal { get }

    var currency: CurrencyProtocol { get }

    init(decimal: Decimal)
}

extension MoneyProtocol {

    static func *(lhs: Self, rhs: Self) -> Self {
        return Self(decimal: lhs.decimal * rhs.decimal)
    }
}

extension MoneyProtocol where IntegerLiteralType == Decimal.IntegerLiteralType {

    static func *(lhs: Self, rhs: Self.IntegerLiteralType) -> Self {
        return Self(decimal: lhs.decimal * Decimal(integerLiteral: rhs))
    }

    static func *(lhs: Self.IntegerLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(integerLiteral: lhs) * rhs.decimal)
    }
}

extension MoneyProtocol where FloatLiteralType == Decimal.FloatLiteralType {

    static func *(lhs: Self, rhs: Self.FloatLiteralType) -> Self {
        return Self(decimal: lhs.decimal * Decimal(floatLiteral: rhs))
    }

    static func *(lhs: Self.FloatLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(floatLiteral: lhs) * rhs.decimal)
    }
}

extension MoneyProtocol {

    static func +(lhs: Self, rhs: Self) -> Self {
        return Self(decimal: lhs.decimal + rhs.decimal)
    }
}

extension MoneyProtocol where IntegerLiteralType == Decimal.IntegerLiteralType {

    static func +(lhs: Self, rhs: Self.IntegerLiteralType) -> Self {
        return Self(decimal: lhs.decimal + Decimal(integerLiteral: rhs))
    }

    static func +(lhs: Self.IntegerLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(integerLiteral: lhs) + rhs.decimal)
    }
}

extension MoneyProtocol where FloatLiteralType == Decimal.FloatLiteralType {

    static func +(lhs: Self, rhs: Self.FloatLiteralType) -> Self {
        return Self(decimal: lhs.decimal + Decimal(floatLiteral: rhs))
    }

    static func +(lhs: Self.FloatLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(floatLiteral: lhs) + rhs.decimal)
    }
}

extension MoneyProtocol {

    static func -(lhs: Self, rhs: Self) -> Self {
        return Self(decimal: lhs.decimal - rhs.decimal)
    }
}

extension MoneyProtocol where IntegerLiteralType == Decimal.IntegerLiteralType {

    static func -(lhs: Self, rhs: Self.IntegerLiteralType) -> Self {
        return Self(decimal: lhs.decimal - Decimal(integerLiteral: rhs))
    }

    static func -(lhs: Self.IntegerLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(integerLiteral: lhs) - rhs.decimal)
    }
}

extension MoneyProtocol where FloatLiteralType == Decimal.FloatLiteralType {

    static func -(lhs: Self, rhs: Self.FloatLiteralType) -> Self {
        return Self(decimal: lhs.decimal - Decimal(floatLiteral: rhs))
    }

    static func -(lhs: Self.FloatLiteralType, rhs: Self) -> Self {
        return Self(decimal: Decimal(floatLiteral: lhs) - rhs.decimal)
    }
}
