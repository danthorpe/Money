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

public struct Currency: CurrencyProtocol {

    public let code: String

    public let scale: Int

    public let symbol: String?

    init(code: String, scale: Int, symbol: String?) {
        self.code = code
        self.scale = scale
        self.symbol = symbol
    }
}

// MARK: - Conformance

extension Currency: Equatable {

    public static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code == rhs.code
            && lhs.scale == rhs.scale
            && lhs.symbol == rhs.symbol
    }
}

// MARK: - Base Currency

extension Currency {

    public class BaseCurrency: CurrencyProtocol, Equatable, CustomStringConvertible {

        public static func ==(lhs: BaseCurrency, rhs: BaseCurrency) -> Bool {
            return lhs.code == rhs.code
                && lhs.scale == rhs.scale
                && lhs.symbol == rhs.symbol
        }

        public let code: String
        public let scale: Int
        public let symbol: String?

        public var description: String {
            guard let symbol = symbol else {
                return "\(code) .\(scale)"
            }
            return "\(symbol)\(code) .\(scale)"
        }

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
            let symbol = nslocale.mny_currencySymbol!

            let fmtr = NumberFormatter()
            fmtr.locale = locale
            fmtr.numberStyle = .currency
            fmtr.currencyCode = code
            fmtr.currencySymbol = symbol

            let scale = fmtr.maximumFractionDigits
            self.init(code: code, scale: scale, symbol: symbol)
        }

        convenience init(locale: Locale) {
            let code = locale.currencyCode!
            let symbol = locale.currencySymbol

            let fmtr = NumberFormatter()
            fmtr.numberStyle = .currency
            fmtr.locale = locale
            fmtr.currencyCode = code

            let scale = fmtr.maximumFractionDigits
            self.init(code: code, scale: scale, symbol: symbol)
        }
    }

    public final class Local: BaseCurrency {
        public static var sharedInstance = Local(locale: Locale.current)
    }
}
