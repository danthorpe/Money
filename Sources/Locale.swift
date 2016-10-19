//
// Money, https://github.com/danthorpe/Money
// Created by Dan Thorpe, @danthorpe
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Daniel Thorpe
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
internal extension NSLocale {

    /// - returns: a String? for the currency code.
    var mny_currencyCode: String? {
        if #available(iOS 10.0, iOSApplicationExtension 10.0, watchOS 3.0, watchOSApplicationExtension 3.0, tvOS 10.0, tvOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *) {
            return currencyCode
        } else {
            return object(forKey: NSLocale.Key.currencyCode) as? String
        }
    }

    /// - returns: a String? for the currency symbol.
    var mny_currencySymbol: String? {
        if #available(iOS 10.0, iOSApplicationExtension 10.0, watchOS 3.0, watchOSApplicationExtension 3.0, tvOS 10.0, tvOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *) {
            return currencySymbol
        } else {
            return object(forKey: NSLocale.Key.currencySymbol) as? String
        }
    }

    /// - returns: a String? for the currency grouping separator.
    var mny_currencyGroupingSeparator: String? {
        return object(forKey: NSLocale.Key.groupingSeparator) as? String
    }

    /// - returns: a String? for the currency decimal separator.
    var mny_currencyDecimalSeparator: String? {
        return object(forKey: NSLocale.Key.decimalSeparator) as? String
    }
}

