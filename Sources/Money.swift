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

struct Money: MoneyProtocol {


    static func *=(lhs: inout Money, rhs: Money) {
        lhs.decimal = lhs.decimal * rhs.decimal
    }

    static func +=(lhs: inout Money, rhs: Money) {
        lhs.decimal = lhs.decimal + rhs.decimal
    }

    static func -=(lhs: inout Money, rhs: Money) {
        lhs.decimal = lhs.decimal - rhs.decimal
    }







    private(set) var decimal: Decimal

    let currency: CurrencyProtocol

    var magnitude: Decimal {
        return decimal
    }





    init(decimal: Decimal = 0, currency: Currency = .device) {
        self.decimal = decimal
        self.currency = currency
    }

    init(decimal: Decimal) {
        self.decimal = decimal
        self.currency = Currency.device
    }

    init(integerLiteral value: Int) {
        self.decimal = Decimal(integerLiteral: value)
        self.currency = Currency.device
    }

    init(floatLiteral value: Double) {
        self.decimal = Decimal(floatLiteral: value)
        self.currency = Currency.device
    }

    init?<T>(exactly source: T) where T : BinaryInteger {
        guard let _decimal = Decimal(exactly: source) else { return nil }
        self.decimal = _decimal
        self.currency = Currency.device
    }



}

// MARK: - Conformance

extension Money: Equatable {

    static func ==(lhs: Money, rhs: Money) -> Bool {
        return lhs.decimal == rhs.decimal
            && lhs.currency.code == rhs.currency.code
            && lhs.currency.scale == rhs.currency.scale
            && lhs.currency.symbol == rhs.currency.symbol
    }
}

