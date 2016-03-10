//
//  Locale.swift
//  Money
//
//  Created by Daniel Thorpe on 22/11/2015.
//
//

import Foundation

/**
 LanguageType provides an interface to retrieve
 a language identifier.
*/
public protocol LanguageType {

    /// - returns: the language identifier as a String
    var languageIdentifier: String { get }
}

/**
 CountryType provides an interface to retrieve
 a country identifier.
 */
public protocol CountryType {

    /// - returns: the country identifier as a String
    var countryIdentifier: String { get }
}

/**
 LocaleType provides an interface to retrieve
 a locale identifier.
 */
public protocol LocaleType {

    /// - returns: the locale identifier as a String
    var localeIdentifier: String { get }
}

/**
 LocaleType extension for types which also conform to
 LanguageType and CountryType.
 */
extension LocaleType where Self: LanguageType, Self: CountryType {

    /**
     Default implementation of localeIdentifier, where
     if a country identifier is not empty, it is appended to the
     language identifier, with an underscore.
    - returns: the locale identifier as a String
    */
    public var localeIdentifier: String {
        guard !countryIdentifier.isEmpty else {
            return languageIdentifier
        }
        return "\(languageIdentifier)_\(countryIdentifier)"
    }
}

/**
 Convenience currency related properties on NSLocale
*/
public extension NSLocale {

    /// - returns: a String? for the currency code.
    var currencyCode: String? {
        return objectForKey(NSLocaleCurrencyCode) as? String
    }

    /// - returns: a String? for the currency symbol.
    var currencySymbol: String? {
        return objectForKey(NSLocaleCurrencySymbol) as? String
    }

    /// - returns: a String? for the currency grouping separator.
    var currencyGroupingSeparator: String? {
        return objectForKey(NSLocaleGroupingSeparator) as? String
    }

    /// - returns: a String? for the currency decimal separator.
    var currencyDecimalSeparator: String? {
        return objectForKey(NSLocaleDecimalSeparator) as? String
    }
}

