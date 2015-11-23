//
//  Locale.swift
//  Money
//
//  Created by Daniel Thorpe on 22/11/2015.
//
//

import Foundation

internal let __formatter = NSNumberFormatter()

public protocol LanguageType {
    var languageIdentifier: String { get }
}

public protocol CountryType {
    var countryIdentifier: String { get }
}

public protocol LocaleType {
    var localeIdentifier: String { get }
}

extension LocaleType where Self: LanguageType, Self: CountryType {
    public var localeIdentifier: String {
        guard !countryIdentifier.isEmpty else {
            return languageIdentifier
        }
        return "\(languageIdentifier)_\(countryIdentifier)"
    }
}

public extension NSLocale {

    var currencyCode: String? {
        return objectForKey(NSLocaleCurrencyCode) as? String
    }

    var currencySymbol: String? {
        return objectForKey(NSLocaleCurrencySymbol) as? String
    }

    var currencyGroupingSeparator: String? {
        return objectForKey(NSLocaleGroupingSeparator) as? String
    }

    var currencyDecimalSeparator: String? {
        return objectForKey(NSLocaleDecimalSeparator) as? String
    }
}

internal extension NSNumberFormatter {
    func reset() {
        currencyCode = nil
        currencySymbol = nil
        internationalCurrencySymbol = nil
        currencyGroupingSeparator = nil
        currencyDecimalSeparator = nil
    }
}