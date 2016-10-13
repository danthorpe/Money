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

internal extension Locale {

    /// - returns: a String? for the currency code.
    var money_currencyCode: String {
//        guard #available(iOSApplicationExtension 10.0, OSXApplicationExtension 10.12, *) else {
//            return self.currencyCode!
//        }
        return self.currencyCode!
    }

    /// - returns: a String? for the currency symbol.
    var money_currencySymbol: String {
//        guard #available(iOSApplicationExtension 10.0, OSXApplicationExtension 10.12, *) else {
//            return self.currencySymbol!
//        }
        return self.currencySymbol!
    }
}

/**
 Convenience currency related properties on NSLocale
*/
public extension Locale {

    /// - returns: a String? for the currency grouping separator.
    var currencyGroupingSeparator: String? {
//        return object(forKey: Key.groupingSeparator) as? String
        return self.groupingSeparator
    }

    /// - returns: a String? for the currency decimal separator.
    var currencyDecimalSeparator: String? {
//        return object(forKey: Key.decimalSeparator) as? String
        return self.decimalSeparator
    }
}



