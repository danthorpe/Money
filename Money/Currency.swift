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

    public static var formatter: NSNumberFormatter {
        return sharedInstance.formatter
    }

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
public struct Currency { }

extension Currency {

    public class BaseCurrency {

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

    public final class Local: BaseCurrency, CurrencyType {
        public static var sharedInstance = Local(locale: NSLocale.currentLocale())
    }    
}

