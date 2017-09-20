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


























extension Currency {

    public class BaseCurrency: CurrencyProtocol, Equatable {

        public static func ==(lhs: BaseCurrency, rhs: BaseCurrency) -> Bool {
            return lhs.code == rhs.code
                && lhs.scale == rhs.scale
                && lhs.symbol == rhs.symbol
        }

        public let code: String
        public let scale: Int
        public let symbol: String?

        init(code: String, scale: Int, symbol: String?) {
            self.code = code
            self.scale = scale
            self.symbol = symbol
        }

        convenience init(code: String) {
            let idFromComponents = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: code])
            let canonical = NSLocale.canonicalLocaleIdentifier(from: idFromComponents)
            let nslocale = NSLocale(localeIdentifier: canonical)
            let locale = Locale(identifier: canonical)
            let symbol = nslocale.currencySymbol

            let fmtr = NumberFormatter()
            fmtr.locale = locale
            fmtr.numberStyle = .currency
            fmtr.currencyCode = code
            fmtr.currencySymbol = symbol

            let scale = fmtr.maximumFractionDigits
            self.init(code: code, scale: scale, symbol: symbol)
        }
    }
}

