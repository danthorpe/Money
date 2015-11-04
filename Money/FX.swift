//
//  FX.swift
//  Money
//
//  Created by Daniel Thorpe on 02/11/2015.
//
//

import Foundation
import Result

/**
 # MoneyPairType
 Used to represent currency pairs. E.g. the pair

 - see: [Wikipedia](https://en.wikipedia.org/wiki/Currency_pair)
 */
public protocol MoneyPairType {

    /// The currency which is being traded/quoted
    typealias CounterMoney: MoneyType

    /// The currency which the quote is in relation to.
    typealias BaseMoney: MoneyType
}

// MARK: - FX Types

/**
 # FXQuote
 The minimum interface required to perform a foreign
 currency exchange.
*/
public class FXQuote {

    /// The exchange rate, stored as a `BankersDecimal`.
    public let rate: BankersDecimal

    /**
     Construct with the rate
    */
    public init(rate: BankersDecimal) {
        self.rate = rate
    }

    /**
     ## Calculate transaction value
     Lets assume we want to convert EUR 100 in to USD. The
     quote type has the rate of EUR/USD stored in a
     bankers decimal. The framework will effectively do
     something like this:

         let eur: EUR = 100
         let usd: USD = rate.transactionValueForBaseValue(eur)

     To support your own quote system (i.e. to add commission)
     Subclass this, and override the this function.
    */
    public func transactionValueForBaseValue<B: MoneyType, C: MoneyType where B.DecimalStorageType == BankersDecimal.DecimalStorageType, C.DecimalStorageType == BankersDecimal.DecimalStorageType>(base: B) -> C {
        return base.convertWithRate(rate)
    }
}

public struct FXTransaction<Base: MoneyType, Counter: MoneyType> {
    let base: Base
    let counter: Counter

    init(base: Base, counter: Counter) {
        self.base = base
        self.counter = counter
    }
}


// MARK: - FX Provider Errors

public enum FXError: ErrorType, Equatable {
    case NetworkError(NSError)
    case NoData
    case InvalidData(NSData)
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

    public static func session() -> NSURLSession {
        return NSURLSession.sharedSession()
    }
}

extension FXRemoteProviderType where BaseMoney.DecimalStorageType == BankersDecimal.DecimalStorageType, CounterMoney.DecimalStorageType == BankersDecimal.DecimalStorageType {

    internal static func fxFromQuoteWithBase(base: BaseMoney) -> FXQuote -> FXTransaction<BaseMoney, CounterMoney> {
        return { quote in
            let counter: CounterMoney = quote.transactionValueForBaseValue(base)
            let transaction = FXTransaction(base: base, counter: counter)
            return transaction
        }
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
            print("We have \(usd)") // We have $89 (or whatever)
         }
    */
    public static func fx(base: BaseMoney, completion: Result<FXTransaction<BaseMoney, CounterMoney>, FXError> -> Void) -> NSURLSessionDataTask {
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

public class Yahoo<Base: MoneyType, Counter: MoneyType>: FXRemoteProvider<Base, Counter>, FXRemoteProviderType {

    public static func name() -> String {
        return "Yahoo \(Base.Currency.code)\(Counter.Currency.code)"
    }

    public static func request() -> NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "http://download.finance.yahoo.com/d/quotes.csv?s=\(BaseMoney.Currency.code)\(CounterMoney.Currency.code)=X&f=nl1d1t1")!)
    }

    public static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<FXQuote, FXError> {
        return result.analysis(

            ifSuccess: { data, response in

                guard let data = data else {
                    return Result(error: .NoData)
                }

                guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
                    return Result(error: .InvalidData(data))
                }

                let components = str.componentsSeparatedByString(",")

                if components.count < 4 {
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

