//
//  Bitcoin.swift
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
import Result
import SwiftyJSON


// MARK: - Bitcoin Currency

protocol BitcoinCurrencyType: CryptoCurrencyType { }

extension Currency {

    /**
     # Currency.XBT
     This is the ISO 4217 currency code, however at the moment
     it is unofficial.
     */
    public struct XBT: BitcoinCurrencyType {
        public static let code = "XBT"
        /// unicode \u{20bf} was accepted as the Bitcoin currency
        /// symbol in November
        public static let symbol = "\u{20BF}"
        /// The smallest unit of Bitcoin is the Satoshi
        /// - see: https://en.bitcoin.it/wiki/Satoshi_(unit)
        public static let scale: Int = 8
        public static let formatter: NSNumberFormatter = {
            let fmtr = NSNumberFormatter()
            fmtr.numberStyle = .CurrencyStyle
            fmtr.maximumFractionDigits = scale
            fmtr.currencySymbol = symbol
            return fmtr
        }()
    }

    /**
     # Currency.BTC
     This is the common code used for Bitcoin,  although it can never become
     the ISO standard as BT is the country code for Bhutan.
     */
    public struct BTC: BitcoinCurrencyType {
        public static let code = "BTC"
        public static let symbol = Currency.XBT.symbol
        public static let scale = Currency.XBT.scale
        public static let formatter = Currency.XBT.formatter
    }
}

public typealias XBT = _Money<Currency.XBT>
public typealias BTC = _Money<Currency.BTC>


// MARK - cex.io FX

public protocol CEXTradeCurrencyType: CurrencyType { }

extension Currency.USD: CEXTradeCurrencyType { }
extension Currency.EUR: CEXTradeCurrencyType { }
extension Currency.RUB: CEXTradeCurrencyType { }

public final class CEX<Counter: MoneyType where Counter.Currency: CEXTradeCurrencyType>: FXRemoteProvider<BTC, Counter>, FXRemoteProviderType {

    public static func name() -> String {
        return "CEX.IO \(BaseMoney.Currency.code)\(CounterMoney.Currency.code)"
    }

    public static func request() -> NSURLRequest {
        let url = NSURL(string: "https://cex.io/api/convert/\(Currency.BTC.code)/\(CounterMoney.Currency.code)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try! JSON(["amnt": Double(1.0)]).rawData()
        request.HTTPBody = data
        return request
    }

    public static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<FXQuote, FXError> {
        return result.analysis(

            ifSuccess: { data, response in

                guard let data = data else {
                    return Result(error: .NoData)
                }

                let json = JSON(data: data)

                if json.isEmpty {
                    return Result(error: .InvalidData(data))
                }

                guard let rate = json["amnt"].double else {
                    return Result(error: .RateNotFound(name()))
                }

                return Result(value: FXQuote(rate: BankersDecimal(floatLiteral: rate)))
            },

            ifFailure: { error in
                return Result(error: .NetworkError(error))
            }
        )
    }
}

