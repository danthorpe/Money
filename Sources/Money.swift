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

public struct Money: MoneyProtocol {

    public static func +=(lhs: inout Money, rhs: Money) {
        let result: Money = lhs + rhs
        lhs.decimal = result.decimal
    }

    public static func -=(lhs: inout Money, rhs: Money) {
        let result: Money = lhs - rhs
        lhs.decimal = result.decimal
    }

    public static func *=(lhs: inout Money, rhs: Money) {
        let result: Money = lhs * rhs
        lhs.decimal = result.decimal
    }

    public static func /=(lhs: inout Money, rhs: Money) {
        let result: Money = lhs / rhs
        lhs.decimal = result.decimal
    }



    public private(set) var decimal: Decimal

    public private(set) var currency: CurrencyProtocol

    public var magnitude: Decimal {
        return decimal
    }





    public init(decimal: Decimal = 0, currency: CurrencyProtocol = Currency.Local.sharedInstance) {
        self.decimal = decimal
        self.currency = currency
    }

    public init(decimal: Decimal) {
        self.init(decimal: decimal, currency: Currency.Local.sharedInstance)
    }

    public init(integerLiteral value: Int) {
        self.init(decimal: Decimal(integerLiteral: value))
    }

    public init(floatLiteral value: Double) {
        self.init(decimal: Decimal(floatLiteral: value))
    }

    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let decimal = Decimal(exactly: source) else { return nil }
        self.init(decimal: decimal)
    }

    public init(minorUnits: Int) {
        self.currency = Currency.Local.sharedInstance
        self.decimal = Decimal(minorUnits).multiplying(byPowersOf10: Int16(currency.scale * -1))
    }


}

// MARK: - Conformance

extension Money: Equatable {

    public static func ==(lhs: Money, rhs: Money) -> Bool {
        return lhs.decimal == rhs.decimal
            && lhs.currency.code == rhs.currency.code
            && lhs.currency.scale == rhs.currency.scale
            && lhs.currency.symbol == rhs.currency.symbol
    }
}

extension Money: Hashable {

    public var hashValue: Int {
        return decimal.hashValue
    }
}

extension Money: Comparable {

    public static func <(lhs: Money, rhs: Money) -> Bool {

        if lhs.currency.code != rhs.currency.code {
            return lhs.currency.code < rhs.currency.code
        }

        return lhs.decimal < rhs.decimal
    }
}

