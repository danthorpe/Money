//
//  Currencies.swift
//  Custom Money
//
//  Created by Daniel Thorpe on 04/11/2015.
//  Copyright © 2015 Daniel Thorpe. All rights reserved.
//

import Foundation
import Money

protocol MyCustomCurrencyType: CustomCurrencyType { }

extension Currency {

    final class Heart: MyCustomCurrencyType {

        static let code: String = "HEARTS"
        static let scale: Int  = 0
        static let formatter: NSNumberFormatter = {
            let fmtr = NSNumberFormatter()
            fmtr.numberStyle = .CurrencyStyle
            fmtr.maximumFractionDigits = Currency.Heart.scale
            fmtr.currencySymbol = "❤️"
            fmtr.internationalCurrencySymbol = Currency.Heart.code
            let locale = NSLocale.currentLocale()
            fmtr.currencyGroupingSeparator = locale.currencyGroupingSeparator
            fmtr.currencyDecimalSeparator = locale.currencyDecimalSeparator
            return fmtr
        }()
    }

    final class Bee: MyCustomCurrencyType {

        static let code: String = "BEES"
        static let scale: Int  = 0
        static let formatter: NSNumberFormatter = {
            let fmtr = NSNumberFormatter()
            fmtr.numberStyle = .CurrencyStyle
            fmtr.maximumFractionDigits = Currency.Bee.scale
            fmtr.currencySymbol = "🐝"
            fmtr.internationalCurrencySymbol = Currency.Bee.code
            let locale = NSLocale.currentLocale()
            fmtr.currencyGroupingSeparator = locale.currencyGroupingSeparator
            fmtr.currencyDecimalSeparator = locale.currencyDecimalSeparator
            return fmtr
        }()
    }
}

typealias Hearts = _Money<Currency.Heart>
typealias Bees = _Money<Currency.Bee>

class BankRates {

    static func quoteForBase(base: String, counter: String) -> FXQuote {
        return FXQuote(rate: sharedInstance.rates[base]![counter]!)
    }

    static let sharedInstance = BankRates()

    let rates: [String: [String: BankersDecimal]]

    init() {
        rates = [
            "BEES": [
                "BEES": 1.1,
                "HEARTS": 0.3
            ],
            "HEARTS": [
                "BEES": 7.3859,
                "HEARTS": 0.8
            ]
        ]
    }
}

class Bank<B: MoneyType, C: MoneyType where
    B.Currency: MyCustomCurrencyType,
    C.Currency: MyCustomCurrencyType,
    B.DecimalStorageType == BankersDecimal.DecimalStorageType,
    C.DecimalStorageType == BankersDecimal.DecimalStorageType>: FXLocalProviderType {

    typealias BaseMoney = B
    typealias CounterMoney = C

    static func name() -> String {
        return "App Bank"
    }

    static func quote() -> FXQuote {
        return BankRates.quoteForBase(BaseMoney.Currency.code, counter: CounterMoney.Currency.code)
    }
}

