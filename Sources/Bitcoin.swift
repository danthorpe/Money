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


// MARK: - Bitcoin Currency

/**
 # Bitcoin Currency Type

 BitcoinCurrencyType is a refinement of CryptoCurrencyType, 
 which allows type restriction when working with Bitcoin.
*/
public protocol BitcoinCurrencyType: CryptoCurrencyType { }

public extension BitcoinCurrencyType {

    /// The smallest unit of Bitcoin is the Satoshi
    /// - see: https://en.bitcoin.it/wiki/Satoshi_(unit)
    static var scale: Int {
        return 8
    }
    
    /// - returns: the currency symbol
    static var symbol: String? {
        return "Ƀ"
    }
}
 
public extension Currency {

    /**
     # Currency.XBT
     This is the ISO 4217 currency code, however at the moment
     it is unofficial.
     
     unicode \u{20bf} was accepted as the Bitcoin currency
     symbol in November. However, it's not yet available
     on Apple platforms. Ƀ is a popular alternative
     which is available.

     */
    struct XBT: BitcoinCurrencyType {

        /// - returns: the proposed ISO 4217 currency code
        public static let code = "XBT"

        /// - returns: a configured NSNumberFormatter
//        public static let formatter: NSNumberFormatter = {
//            let fmtr = NSNumberFormatter()
//            fmtr.numberStyle = .CurrencyStyle
//            fmtr.maximumFractionDigits = scale
//            fmtr.currencySymbol = "Ƀ"
//            return fmtr
//        }()
    }

    /**
     # Currency.BTC
     This is the common code used for Bitcoin,  although it can never become
     the ISO standard as BT is the country code for Bhutan.
     */
    struct BTC: BitcoinCurrencyType {
        public static let code = "BTC"
//        public static let scale = Currency.XBT.scale
//        public static let formatter = Currency.XBT.formatter
    }
}

/// The proposed ISO 4217 Bitcoin MoneyType
public typealias XBT = _Money<Currency.XBT>

/// The most commonly used Bitcoin MoneyType
public typealias BTC = _Money<Currency.BTC>


