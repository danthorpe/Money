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

public enum CurrencyMarketTransactionKind {
    case Buy, Sell
}

public protocol CurrencyMarketTransactionType: MoneyPairType {
    static var transactionKind: CurrencyMarketTransactionKind { get }
}

public protocol CryptoCurrencyMarketTransactionType: CurrencyMarketTransactionType {
    typealias FiatCurrency: CurrencyType
}

struct _CEXBuy<Counter: MoneyType where Counter.Currency: CEXTradeCurrencyType>: CryptoCurrencyMarketTransactionType {
    typealias BaseMoney = BTC
    typealias CounterMoney = Counter
    typealias FiatCurrency = Counter.Currency
    static var transactionKind: CurrencyMarketTransactionKind { return .Buy }
}

struct _CEXSell<Base: MoneyType where Base.Currency: CEXTradeCurrencyType>: CryptoCurrencyMarketTransactionType {
    typealias BaseMoney = Base
    typealias CounterMoney = BTC
    typealias FiatCurrency = Base.Currency
    static var transactionKind: CurrencyMarketTransactionKind { return .Sell }
}

public class _CEX<Transaction: CryptoCurrencyMarketTransactionType where Transaction.FiatCurrency: CEXTradeCurrencyType>: FXRemoteProvider<Transaction.BaseMoney, Transaction.CounterMoney>, FXRemoteProviderType {

    public static func name() -> String {
        return "CEX.IO \(BaseMoney.Currency.code)\(CounterMoney.Currency.code)"
    }

    public static func request() -> NSURLRequest {
        let url = NSURL(string: "https://cex.io/api/convert/\(BTC.Currency.code)/\(Transaction.FiatCurrency.code)")
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

                guard let rateLiteral = json["amnt"].double else {
                    return Result(error: .RateNotFound(name()))
                }

                let rate: BankersDecimal

                switch Transaction.transactionKind {
                case .Buy:
                    rate = BankersDecimal(floatLiteral: rateLiteral)
                case .Sell:
                    rate = BankersDecimal(floatLiteral: rateLiteral).reciprocal
                }

                return Result(value: FXQuote(rate: rate))
            },

            ifFailure: { error in
                return Result(error: .NetworkError(error))
            }
        )
    }
}

public class CEXBuy<Counter: MoneyType where Counter.Currency: CEXTradeCurrencyType>: _CEX<_CEXBuy<Counter>> { }
public class CEXSell<Base: MoneyType where Base.Currency: CEXTradeCurrencyType>: _CEX<_CEXSell<Base>> { }



