//
//  Currency.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

public protocol CurrencyType: DecimalNumberBehaviorType {
    static var sharedInstance: Self { get }

    var locale: NSLocale { get }
    var formatter: NSNumberFormatter { get }
}

extension CurrencyType {

    /// Returns a formatter from the shared instance
    public static var formatter: NSNumberFormatter {
        return sharedInstance.formatter
    }

    /// The currency code
    public static var code: String {
        return sharedInstance.formatter.currencyCode
    }

    /// The currency symbol
    public static var symbol: String {
        return sharedInstance.formatter.currencySymbol
    }

    /// The currency scale
    public static var scale: Int {
        return formatter.maximumFractionDigits
    }

    public static var decimalNumberBehaviors: NSDecimalNumberBehaviors? {
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

        public let formatter: NSNumberFormatter
        public let locale: NSLocale

        init(locale: NSLocale) {
            self.formatter = {
                let fmtr = NSNumberFormatter()
                fmtr.numberStyle = .CurrencyStyle
                fmtr.locale = locale
                return fmtr
            }()
            self.locale = locale
        }

        convenience init(code: String) {
            self.init(locale: NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents([NSLocaleCurrencyCode: code])))
        }
    }

    /**
     # Currency.Local
     `Currency.Local` is a `BaseCurrency` subclass which represents
     the device's current currency, using `NSLocale.currencyLocale()`.
     */
    public final class Local: Currency.Base, CurrencyType {
        public static var sharedInstance = Local(locale: NSLocale.currentLocale())
    }
}



