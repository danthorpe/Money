//
//  Currency.swift
//  Money
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
 # CurrencyType
 This protocol defines the minimum interface needed for a 
 CurrencyType.
 
 The interface used to represent a single currency. Note
 that it is always used as a generic constraint on other
 types.
 
 Typically framework consumers will not need to conform to
 this protocol, unless creating their own currencies. See
 the example project "Custom Money" for an example of this.
*/
public protocol CurrencyType: DecimalNumberBehaviorType {

    /// The currency code
    static var code: String { get }

    /// The currency scale
    static var scale: Int { get }

    /// The currency symbol
    static var symbol: String? { get }

    /// A number formatter for the currency
    static var formatter: NSNumberFormatter { get }

    static func formattedWithStyle(style: NSNumberFormatterStyle, forLocaleId localeId: String) -> NSDecimalNumber -> String

    static func formattedWithStyle(style: NSNumberFormatterStyle, forLocale locale: Locale) -> NSDecimalNumber -> String
}

public extension CurrencyType {

    static var symbol: String? {
        return formatter.currencySymbol
    }

    /**
     Default implementation of the `NSDecimalNumberBehaviors` for
     the currency. This uses `NSRoundingMode.RoundBankers` and the
     scale of the currency as given by the localized formatter.
     
     - returns: a `NSDecimalNumberBehaviors`
    */
    static var decimalNumberBehaviors: NSDecimalNumberBehaviors {
        return NSDecimalNumberHandler(
            roundingMode: .RoundBankers,
            scale: Int16(scale),
            raiseOnExactness: true,
            raiseOnOverflow: true,
            raiseOnUnderflow: true,
            raiseOnDivideByZero: true
        )
    }
}

internal extension CurrencyType {

    static func formattedWithStyle(style: NSNumberFormatterStyle, forLocale locale: NSLocale) -> NSDecimalNumber -> String {
        __formatter.reset()
        __formatter.locale = locale
        __formatter.numberStyle = style
        switch locale.currencyCode {
        case .Some(let wrapped) where wrapped == code:
            break
        default:
            __formatter.currencyCode = code
            __formatter.currencySymbol = formatter.currencySymbol
            __formatter.internationalCurrencySymbol = formatter.internationalCurrencySymbol
            __formatter.currencyGroupingSeparator = formatter.currencyGroupingSeparator
            __formatter.currencyDecimalSeparator = formatter.currencyDecimalSeparator
            __formatter.maximumFractionDigits = formatter.maximumFractionDigits

        }
        return { __formatter.stringFromNumber($0)! }
    }
}


/**
 Custom currency types should refine CustomCurrencyType.

 This is to benefit from default implementations of string
 formatting.
*/
public protocol CustomCurrencyType: CurrencyType { }

public extension CustomCurrencyType {

    /**
     Use the provided locale identifier to format a supplied NSDecimalNumber.
     
     - returns: a NSDecimalNumber -> String closure.
    */
    static func formattedWithStyle(style: NSNumberFormatterStyle, forLocaleId localeId: String) -> NSDecimalNumber -> String {
        let locale = NSLocale(localeIdentifier: NSLocale.canonicalLocaleIdentifierFromString(localeId))
        return formattedWithStyle(style, forLocale: locale)
    }

    /**
     Use the provided Local to format a supplied NSDecimalNumber.

     - returns: a NSDecimalNumber -> String closure.
     */
    static func formattedWithStyle(style: NSNumberFormatterStyle, forLocale locale: Locale) -> NSDecimalNumber -> String {
        return formattedWithStyle(style, forLocaleId: locale.localeIdentifier)
    }
}

/**
 Crypto currency types (Bitcoin etc) should refine CryptoCurrencyType.

 This is to benefit from default implementations.
*/
public protocol CryptoCurrencyType: CustomCurrencyType { }

/**
 `ISOCurrencyType` is a refinement of `CurrencyType` so that
 the ISO currencies can be autogenerated.
*/
public protocol ISOCurrencyType: CurrencyType {

    /** 
     A shared instance of the currency. Note that static
     variables are lazily created.
    */
    static var sharedInstance: Self { get }

    /// - returns: the currency code
    var _code: String { get }

    /// - returns: a number formatter for the currency in the current locale.
    var _formatter: NSNumberFormatter { get }
}

public extension ISOCurrencyType {

    /// The currency code
    static var code: String {
        return sharedInstance._code
    }

    /// The currency scale
    static var scale: Int {
        return formatter.maximumFractionDigits
    }

    /// Returns a formatter from the shared instance
    static var formatter: NSNumberFormatter {
        return sharedInstance._formatter
    }

    /**
     Use the provided locale identifier to format a supplied NSDecimalNumber.

     - returns: a NSDecimalNumber -> String closure.
     */
    static func formattedWithStyle(style: NSNumberFormatterStyle, forLocaleId localeId: String) -> NSDecimalNumber -> String {
        let id = "\(NSLocale.currentLocale().localeIdentifier)@currency=\(code)"
        let locale = NSLocale(localeIdentifier: NSLocale.canonicalLocaleIdentifierFromString(id))
        return formattedWithStyle(style, forLocale: locale)
    }

    /**
     Use the provided Local to format a supplied NSDecimalNumber.

     - returns: a NSDecimalNumber -> String closure.
     */
    static func formattedWithStyle(style: NSNumberFormatterStyle, forLocale locale: Locale) -> NSDecimalNumber -> String {
        let id = "\(locale.localeIdentifier)@currency=\(code)"
        let locale = NSLocale(localeIdentifier: NSLocale.canonicalLocaleIdentifierFromString(id))
        return formattedWithStyle(style, forLocale: locale)
    }
}

/**
 # Currency
 A namespace for currency related types.
*/
public struct Currency {

    /**

     # Currency.Base
     
     `Currency.Base` is a class which composes a number formatter
     and a locale. It doesn't conform to `CurrencyType` but it can
     be used as a base class for currency types which only require
     a shared instance.
     */
    public class Base {

        public let _code: String

        public lazy var _formatter: NSNumberFormatter = {
            let fmtr = NSNumberFormatter()
            let locale = NSLocale(localeIdentifier: NSLocale.canonicalLocaleIdentifierFromString(NSLocale.localeIdentifierFromComponents([NSLocaleCurrencyCode: self._code])))
            fmtr.numberStyle = .CurrencyStyle
            fmtr.currencyCode = self._code
            fmtr.currencySymbol = locale.currencySymbol
            return fmtr
        }()

        init(code: String) {
            self._code = code
        }

        convenience init(locale: NSLocale) {
            self.init(code: locale.objectForKey(NSLocaleCurrencyCode) as! String)
        }
    }

    /**
     
     # Currency.Local
     
     `Currency.Local` is a `BaseCurrency` subclass which represents
     the device's current currency, using `NSLocale.currentLocale()`.
     */
    public final class Local: Currency.Base, ISOCurrencyType {
        public static var sharedInstance = Local(locale: NSLocale.currentLocale())
    }
}
