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

public struct ISOMoney<C: ISOCurrencyProtocol>: MoneyProtocol {

    public static func +=(lhs: inout ISOMoney<C>, rhs: ISOMoney<C>) {
        let result: ISOMoney<C> = lhs + rhs
        lhs.decimal = result.decimal
    }

    public static func -=(lhs: inout ISOMoney<C>, rhs: ISOMoney<C>) {
        let result: ISOMoney<C> = lhs - rhs
        lhs.decimal = result.decimal
    }

    public static func *=(lhs: inout ISOMoney<C>, rhs: ISOMoney<C>) {
        let result: ISOMoney<C> = lhs * rhs
        lhs.decimal = result.decimal
    }

    public static func /=(lhs: inout ISOMoney<C>, rhs: ISOMoney<C>) {
        let result: ISOMoney<C> = lhs / rhs
        lhs.decimal = result.decimal
    }


    public let currency: CurrencyProtocol = C.shared

    public private(set) var decimal: Decimal



    public var magnitude: Decimal {
        return decimal
    }



    public init(decimal: Decimal = 0) {
        self.decimal = decimal
    }

    public init(integerLiteral value: Int) {
        self.decimal = Decimal(integerLiteral: value)
    }

    public init(floatLiteral value: Double) {
        self.decimal = Decimal(floatLiteral: value)
    }

    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let _decimal = Decimal(exactly: source) else { return nil }
        self.decimal = _decimal
    }

    public init(minorUnits: Int) {
        self.init(decimal: Decimal(minorUnits).multiplying(byPowersOf10: Int16(C.shared.scale * -1)))
    }

}

// MARK: - Conformance

extension ISOMoney: Equatable {

    public static func ==(lhs: ISOMoney<C>, rhs: ISOMoney<C>) -> Bool {
        return lhs.decimal == rhs.decimal
            && lhs.currency.code == rhs.currency.code
            && lhs.currency.scale == rhs.currency.scale
            && lhs.currency.symbol == rhs.currency.symbol
    }
}

extension ISOMoney: Comparable {

    public static func <(lhs: ISOMoney<C>, rhs: ISOMoney<C>) -> Bool {

        if lhs.currency.code != rhs.currency.code {
            return lhs.currency.code < rhs.currency.code
        }

        return lhs.decimal < rhs.decimal
    }
}

