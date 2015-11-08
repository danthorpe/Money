//
//  OpenExchangeRates.swift
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
import ValueCoding
import Result
import SwiftyJSON


// MARK: - Open Exchange Rates FX Service Provider

/**
# Open Exchange Rates
Open Exchange Rates (OER) is a popular FX provider,
which does have a "forever free" service, which will
only return rates for all supported currencies with
USD as the base currency.

Paid for access allows specification of the base &
counter currency.

All access requires an "app_id", even the forever
free one.

This protocol defines a type which can return the
app_id. Therefore, consumers should define their
own type which conforms, and then using whatever
mechanism you want, return your OER app_id. I
recommend using something like [CocoaPod Keys](https://github.com/orta/cocoapods-keys)

Lets say, you create this...


struct MyOpenExchangeRatesAppID: OpenExchangeRatesAppID {
static let app_id = "blarblarblarblar"
}

Now, create subclasses of `_OpenExchangeRates` or
`_ForeverFreeOpenExchangeRates` depending on your access level.

e.g. If you have a forever free app_id:


class OpenExchangeRates<Counter: MoneyType>: _ForeverFreeOpenExchangeRates<Counter, MyOpenExchangeRatesAppID> { }

usage would then be like this:


let usd: USD = 100
OpenExchangeRates<GBP>.fx(usd) { result in
// etc, result will include the GBP exchanged for US$ 100
}

If you have paid for access to OpenExchangeRates then instead
create the following subclass:


class OpenExchangeRates<Base: MoneyType, Counter: MoneyType>: _OpenExchangeRates<Base, Counter, MyOpenExchangeRatesAppID> { }

- see: [https://openexchangerates.org](https://openexchangerates.org)
- see: [CocoaPod Keys](https://github.com/orta/cocoapods-keys)

*/
public protocol OpenExchangeRatesAppID {
    static var app_id: String { get }
}

/**
 # Open Exchange Rates
 Base class for OpenExchangeRates.org. See the docs above.

 - see: `OpenExchangeRatesAppID`
 */
public class _OpenExchangeRates<Base: MoneyType, Counter: MoneyType, ID: OpenExchangeRatesAppID>: FXRemoteProvider<Base, Counter>, FXRemoteProviderType {

    public static func name() -> String {
        return "OpenExchangeRates.org \(Base.Currency.code)\(Counter.Currency.code)"
    }

    public static func request() -> NSURLRequest {
        var url = NSURL(string: "https://openexchangerates.org/api/latest.json?app_id=\(ID.app_id)")!

        switch BaseMoney.Currency.code {
        case Currency.USD.code:
            break
        default:
            url = url.URLByAppendingPathComponent("&base=\(BaseMoney.Currency.code)")
        }

        return NSURLRequest(URL: url)
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

                guard let rate = json[["rates", CounterMoney.Currency.code]].double else {
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

/**
 # Open Exchange Rates
 Forever Free class for OpenExchangeRates.org. See the docs above.

 - see: `OpenExchangeRatesAppID`
 */
public class _ForeverFreeOpenExchangeRates<Counter: MoneyType, ID: OpenExchangeRatesAppID>: _OpenExchangeRates<USD, Counter, ID> { }






