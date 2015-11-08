//
//  Yahoo.swift
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


// MARK: - Yahoo FX Service Provider

/**
# Yahoo FX
This type uses Yahoo's Currency Converter. E.g.

It is generic over two `MoneyType`s, and is only
used as a type - there is no initializer.

```swift
Yahoo<USD,JPY>.fx(100) { jpy in
print("\(jpy)") // is a Result<JPY,FXError>
}
```

*/
public final class Yahoo<Base: MoneyType, Counter: MoneyType>: FXRemoteProvider<Base, Counter>, FXRemoteProviderType {

    /**
     Access the name of the FX provider (e.g. "Yahoo USDEUR")

     - returns: a `String`.
     */
    public static func name() -> String {
        return "Yahoo \(Base.Currency.code)\(Counter.Currency.code)"
    }

    /**
     Constructs the `NSURLRequest` to Yahoo's currency convertor service.

     - returns: a `NSURLRequest`.
     */
    public static func request() -> NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "https://download.finance.yahoo.com/d/quotes.csv?s=\(BaseMoney.Currency.code)\(CounterMoney.Currency.code)=X&f=nl1")!)
    }

    /**
     This function is used to map the network result into a quote.

     - paramter result: the network result, represented as `Result<T,E>` where
     the value, T, is a tuple of data and response. The error, E, is an `NSError`.
     - returns: a `Result<FXQuote, FXError>`.
     */
    public static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<FXQuote, FXError> {
        return result.analysis(

            ifSuccess: { data, response in

                guard let data = data else {
                    return Result(error: .NoData)
                }

                guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
                    return Result(error: .InvalidData(data))
                }

                let components = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).componentsSeparatedByString(",")

                if components.count < 2 {
                    return Result(error: .InvalidData(data))
                }

                guard let rate = Double(components[1]) else {
                    return Result(error: .RateNotFound(str))
                }

                return Result(value: FXQuote(rate: BankersDecimal(floatLiteral: rate)))
            },

            ifFailure: { error in
                return Result(error: .NetworkError(error))
            }
        )
    }
}
