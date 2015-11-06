//
//  FX.swift
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

/**
 # MoneyPairType
 Used to represent currency pairs.

 - see: [Wikipedia](https://en.wikipedia.org/wiki/Currency_pair)
 */
public protocol MoneyPairType {

    /// The currency which the quote is in relation to.
    typealias BaseMoney: MoneyType

    /// The currency which is being traded/quoted
    typealias CounterMoney: MoneyType
}

// MARK: - FX Types

/**
 # Quote
 The minimum interface required to perform a foreign
 currency exchange.
*/
public class FXQuote: NSObject, NSCoding {

    /// The exchange rate, stored as a `BankersDecimal`.
    public let rate: BankersDecimal

    /**
     Construct with the rate
    */
    public init(rate: BankersDecimal) {
        self.rate = rate
    }

    public required init?(coder aDecoder: NSCoder) {
        rate = BankersDecimal.decode(aDecoder.decodeObjectForKey("rate"))!
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(rate.encoded, forKey: "rate")
    }

    /**
     ## Calculate transaction value
     Lets assume we want to convert EUR 100 in to USD. The
     quote type has the rate of EUR/USD stored in a
     bankers decimal. The framework will effectively do
     something like this:

         let eur: EUR = 100
         let usd: USD = rate.transactionValueForBaseValue(eur)

     Most foreign exchange services will build their commission
     into their rates. So to implement a provider for a serivce
     can work just like the `Yahoo` one here.
    */
    public func transactionValueForBaseValue<B: MoneyType, C: MoneyType where B.DecimalStorageType == BankersDecimal.DecimalStorageType, C.DecimalStorageType == BankersDecimal.DecimalStorageType>(base: B) -> C {
        return base.convertWithRate(rate)
    }
}

// MARK: - FX Provider Errors

/**
 # FXError
 This is an error type used in FX methods.
*/
public enum FXError: ErrorType, Equatable {

    /// When there is a network error
    case NetworkError(NSError)

    /// If there was no data/response
    case NoData

    /// If the data was corrupted or invalid
    case InvalidData(NSData)

    /// If a rate could not be found
    case RateNotFound(String)
}

/**
 # FX Provider
 `FXProviderType` defines the interface for a FX
 provider.
 
 `FXProviderType` refines `CurrencyPairType` which
 means that FX Providers should be generic types. E.g.
 
     AcmeFX<EUR, USD>
 
 would be the provider type, to exchange EUR to USD 
 using AcmeFX services.
*/
public protocol FXProviderType: MoneyPairType {

    /// The name of the provider.
    static func name() -> String
}

// MARK: - Protocol: Local Provider

/**
 # FX Local Provider
 `FXLocalProvider` defines an interface for a FX service
 which stores its rates locally, and can make synchronous
 exchanges.

 A typical usage for this would be when converting between
 your applications custom currencies, for example in a game.
*/
public protocol FXLocalProviderType: FXProviderType {

    /**
     Generate the quote using the `BaseMoney` and 
     `CounterMoney` generic types.
    
     - returns: a `FXQuote` which contains the rate.
    */
    static func quote() -> FXQuote
}

extension FXLocalProviderType where BaseMoney.DecimalStorageType == BankersDecimal.DecimalStorageType, CounterMoney.DecimalStorageType == BankersDecimal.DecimalStorageType {

    /**
     This is the primary API used to determine for Foreign Exchange transactions.
     */
    public static func fx(base: BaseMoney) -> CounterMoney {
        return base.convertWithRate(quote().rate)
    }
}

// MARK: - Protocol: Remote Provider

/**
 FX Providers which get their rates via a network request
 should conform to `FXRemoteProviderType`, which defines
 how the network request should be made.
*/
public protocol FXRemoteProviderType: FXProviderType {

    /**
     Return the NSURLSession to use to make the request. It 
     should be notes that this session must be retained by
     something in memory, e.g. use a shared session, or
     a session owned by a singleton.
     
     By default, returns `NSURLSession.sharedSession()`.

     - returns: a `NSURLSession`.
    */
    static func session() -> NSURLSession

    /**
     Create a suitable NSURLRequest to convert from the
     base currency code to the target currency code.

     Typically, these will just be contatanted together
     to form a ticker, however, some providers may use
     query paramters.

     - parameter base: the currency code of the base currency, a `String`
     - parameter symbol: the currency code of the target currency, a `String`
     - returns: a `NSURLRequest`
     */
    static func request() -> NSURLRequest

    /**
     Parse the received NSData into the providers own QuoteType. More
     than likely, this will just be `FXQuote`, but providers may
     support fees/commission info which needs representing.

     - parameter data: the `NSData` received from the service provider
     - returns: a `Result` generic over the `QuoteType` and `FX.Error` which
     supports general errors for mal-formed or missing information.
     */
    static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<FXQuote, FXError>
}

// MARK: - FXRemoteProviderType Extension

extension FXRemoteProviderType {

    /**
     Default implementation to return the shared
     `NSURLSession`.
    */
    public static func session() -> NSURLSession {
        return NSURLSession.sharedSession()
    }
}

extension FXRemoteProviderType where BaseMoney.DecimalStorageType == BankersDecimal.DecimalStorageType, CounterMoney.DecimalStorageType == BankersDecimal.DecimalStorageType {

    internal static func fxFromQuoteWithBase(base: BaseMoney) -> FXQuote -> CounterMoney {
        return { $0.transactionValueForBaseValue(base) }
    }

    /**
     # FX
     This is the primary API used to determine for Foreign Exchange transactions. Using the
     `Yahoo` FX Provider as an example, we would use it like this..
     
         let gbp: GBP = 100 // We have £100
         Yahoo<GBP, USD>.fx(gbp) { result in
            guard let usd = result.value?.counter else {
                print("Received an `FXError`")
            }
            print("We have \(usd)") // We have $119 (or whatever)
         }
    */
    public static func fx(base: BaseMoney, completion: Result<CounterMoney, FXError> -> Void) -> NSURLSessionDataTask {
        let client = FXServiceProviderNetworkClient(session: session())
        let fxFromQuote = fxFromQuoteWithBase(base)
        return client.get(request(), adaptor: quoteFromNetworkResult) { completion($0.map(fxFromQuote)) }
    }
}

// MARK: - FX Network Client

internal class FXServiceProviderNetworkClient {
    let session: NSURLSession

    init(session: NSURLSession = NSURLSession.sharedSession()) {
        self.session = session
    }

    func get(request: NSURLRequest, adaptor: Result<(NSData?, NSURLResponse?), NSError> -> Result<FXQuote, FXError>, completion: Result<FXQuote, FXError> -> Void) -> NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            let result = error.map { Result(error: $0) } ?? Result(value: (data, response))
            completion(adaptor(result))
        }
        task.resume()
        return task
    }
}

public class FXRemoteProvider<B: MoneyType, T: MoneyType> {
    public typealias BaseMoney = B
    public typealias CounterMoney = T
}

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
     Access the name of the FX provider (e.g. "Yahoo USDEUR"
     
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








public func ==(lhs: FXError, rhs: FXError) -> Bool {
    switch (lhs, rhs) {
    case let (.NetworkError(aError), .NetworkError(bError)):
        return aError.isEqual(bError)
    case (.NoData, .NoData):
        return true
    case let (.InvalidData(aData), .InvalidData(bData)):
        return aData.isEqualToData(bData)
    case let (.RateNotFound(aStr), .RateNotFound(bStr)):
        return aStr == bStr
    default:
        return false
    }
}

