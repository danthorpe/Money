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

/**
 # CurrencyProtocol

 This protocol defines the minimum interface needed for
 a CurrencyProtocol.

 The interface is used to represent a single currency.
 */
public protocol CurrencyProtocol {

    /// The currency code
    var code: String { get }

    /// The currency scale
    var scale: Int { get }

    /// The currency symbol
    var symbol: String? { get }

    /// Create a number formatter
    func numberFormatter(withStyle: NumberFormatter.Style, forLocaleId: String) -> NumberFormatter
}

public protocol ISOCurrencyProtocol: CurrencyProtocol {

    static var shared: Self { get }
}


public extension CurrencyProtocol {

    func numberFormatter(withStyle style: NumberFormatter.Style, forLocaleId localeId: String) -> NumberFormatter {
        let canonicalId = Locale.canonicalIdentifier(from: localeId)
        let locale = Locale(identifier: "\(canonicalId)@currency=\(code)")
        return numberFormatter(withStyle: style, for: locale)
    }

    func numberFormatter(withStyle style: NumberFormatter.Style, for locale: Locale) -> NumberFormatter {

        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = style
        formatter.currencyCode = code
        formatter.currencySymbol = symbol ?? locale.currencySymbol
        return formatter
    }

    func makeDecimalFormatter(withStyle style: NumberFormatter.Style, for locale: Locale) -> (NSDecimalNumber) -> String {
        let formatter = numberFormatter(withStyle: style, for: locale)
        return { formatter.string(from: $0) ?? $0.description }
    }
}

