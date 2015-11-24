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

/**
 An enum to define the transaction from the perspective
 of the user. i.e. either a buy or sell.
*/
public enum CurrencyMarketTransactionKind {
    /// User is performing a buy transaction
    case Buy
    /// User is performing a sell transaction
    case Sell
}

/**
 A protocol to define a currency market transaction. It refines
 MoneyPairType. It exposes the kind of transaction as a property.
*/
public protocol CurrencyMarketTransactionType: MoneyPairType {

    /// - returns: the transactionKind, a CurrencyMarketTransactionKind
    static var transactionKind: CurrencyMarketTransactionKind { get }
}

/**
 A protocol to define a crypto currency market transaction. It refines
 CurrencyMarketTransactionType, and adds a new typealias for the FiatCurrency.
 
 By crypto currency market transaction, we refer to a currency exchange 
 involving a crypto currency, such as bitcoin, or litecoin or similar.
 
 A Fiat Currency is a currency which is maintained by a national bank, such as
 USD, or EUR.
 
 Typrically a crypto currency market transaction is where the user is purchasing
 bitcoin with USD, or selling bitcoin for USD.
*/
public protocol CryptoCurrencyMarketTransactionType: CurrencyMarketTransactionType {
    typealias FiatCurrency: ISOCurrencyType
}

/**
 # Quote
 Represents an FX quote with a rate and commision
 percentage. By default the percentage is 0.
*/
public struct FXQuote: ValueCoding {

    /// The Coder required for ValueCoding
    public typealias Coder = FXQuoteCoder

    /// The exchange rate, stored as a `BankersDecimal`.
    public let rate: BankersDecimal

    /// The commission as a percentage, e.g. 0.2 => 0.2%
    public let percentage: BankersDecimal

    /**
     Construct with a rate and commission percentage (defaults to
     zero).
     
     - parameter rate: a `BankersDecimal`.
     - parameter percentage: a `BankersDecimal`.
     - returns: a `FXQuote`
    */
    public init(rate: BankersDecimal, percentage: BankersDecimal = 0) {
        self.rate = rate
        self.percentage = percentage
    }

    /**
     ## Calculate the commission.
     Taken as the ammount of the base currency.
    */
    public func commission<B : MoneyType where B.DecimalStorageType == BankersDecimal.DecimalStorageType>(base: B) -> B {
        return (percentage / 100) * base
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
        return ((1 - (percentage / 100)) * base).convertWithRate(rate)
    }
}

/**
 FXTransaction is a generic value type which represents a
 foreign currency transaction. It is generic over two
 MoneyType.
 
 There are some restrictions on the two generic types, to support
 the mathematics and ValueCoding. However, essentially, if you use
 _Money then these are limitations are all met.
 
 - see: MoneyPairType
*/
public struct FXTransaction<Base, Counter where
    Base: MoneyType,
    Base.Coder: NSCoding,
    Base.Coder.ValueType == Base,
    Base.DecimalStorageType == BankersDecimal.DecimalStorageType,
    Counter: MoneyType,
    Counter.Coder: NSCoding,
    Counter.Coder.ValueType == Counter,
    Counter.DecimalStorageType == BankersDecimal.DecimalStorageType>: MoneyPairType, ValueCoding {

    public typealias Coder = FXTransactionCoder<BaseMoney, CounterMoney>
    public typealias BaseMoney = Base
    public typealias CounterMoney = Counter

    /// - returns: the BaseMoney value.
    public let base: BaseMoney

    /// - returns: the BaseMoney commission.
    public let commission: BaseMoney

    /// - returns: the rate, a BankersDecimal.
    public let rate: BankersDecimal

    /// - returns: the CounterMoney value.
    public let counter: CounterMoney

    internal init(base: BaseMoney, commission: BaseMoney, rate: BankersDecimal, counter: CounterMoney) {
        self.base = base
        self.commission = commission
        self.rate = rate
        self.counter = counter
    }

    /**
     A FXTransaction can be created with the BaseMoney value (i.e. how much money
     is being exchanged), and the FXQuote value. Using the quote, the
     counter value (i.e. how much is received) and commission (i.e. how much of 
     the base is spent on commission) is automatically calculated.
     
     - parameter base: the value for base
     - parameter quote: a FXQuote
     - returns: an initialized FXTransaction value
    */
    public init(base: BaseMoney, quote: FXQuote) {
        self.base = base
        self.commission = quote.commission(base)
        self.rate = quote.rate
        self.counter = quote.transactionValueForBaseValue(base)
    }
}

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

extension FXLocalProviderType where
    BaseMoney.Coder: NSCoding,
    BaseMoney.Coder.ValueType == BaseMoney,
    BaseMoney.DecimalStorageType == BankersDecimal.DecimalStorageType,
    CounterMoney.Coder: NSCoding,
    CounterMoney.Coder.ValueType == CounterMoney,
    CounterMoney.DecimalStorageType == BankersDecimal.DecimalStorageType {

    public typealias Transaction = FXTransaction<BaseMoney, CounterMoney>

    /**
     This is the primary API used to determine for Foreign Exchange transactions.
     */
    public static func fx(base: BaseMoney) -> Transaction {
        return Transaction(base: base, quote: quote())
    }
}

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

extension FXRemoteProviderType {

    /**
     Default implementation to return the shared
     `NSURLSession`.
    */
    public static func session() -> NSURLSession {
        return NSURLSession.sharedSession()
    }
}

extension FXRemoteProviderType where
    BaseMoney.Coder: NSCoding,
    BaseMoney.Coder.ValueType == BaseMoney,
    BaseMoney.DecimalStorageType == BankersDecimal.DecimalStorageType,
    CounterMoney.Coder: NSCoding,
    CounterMoney.Coder.ValueType == CounterMoney,
    CounterMoney.DecimalStorageType == BankersDecimal.DecimalStorageType {

    public typealias Transaction = FXTransaction<BaseMoney, CounterMoney>

    internal static func fxFromQuoteWithBase(base: BaseMoney) -> FXQuote -> Transaction {
        return { Transaction(base: base, quote: $0) }
    }

    /**
     # FX - Get Quote
     This is the primary API used to determine for Foreign Exchange transactions. Using the
     `Yahoo` FX Provider as an example, we would use it like this..

        Yahoo<GBP, USD>.quote(100) { result in
             guard let (pounds, quote, usd) = result.value else {
                 error("Received an `FXError`")
             }
             print("Exchanged \(pounds) into \(usd) with a rate of \(quote.rate)")
          }
     
      - parameter base: the `BaseMoney` which is a `MoneyType`. Because it's literal 
     convertible, this can receive a literal if you're just playing.
      - parameter completion: a completion block which receives a `Result<T, E>`. 
     The error is an `FXError` value, and the result "value" is a tuple, of the
     base money, the quote, and the counter money, or `(BaseMoney, FXQuote, CounterMoney)`.
     - returns: an `NSURLSessionDataTask`.
     */
    public static func quote(base: BaseMoney, completion: Result<Transaction, FXError> -> Void) -> NSURLSessionDataTask {
        let client = FXServiceProviderNetworkClient(session: session())
        let fxFromQuote = fxFromQuoteWithBase(base)
        return client.get(request(), adaptor: quoteFromNetworkResult) { completion($0.map(fxFromQuote)) }
    }

    /**
     # FX - Get Counter Money
     This is a convenience API used to determine for Foreign Exchange transactions. Using the
     `Yahoo` FX Provider as an example, we would use it like this..

         Yahoo<GBP, USD>.fx(100) { result in
            guard let usd = result.value?.counter else {
                print("Received an `FXError`")
            }
            print("We have \(usd)") // We have $119 (or whatever)
         }
     - parameter base: the `BaseMoney` which is a `MoneyType`. Because it's literal
     convertible, this can receive a literal if you're just playing.
     - parameter completion: a completion block which receives a `Result<T, E>`.
     The error is an `FXError` value, and the result "value" is the `CounterMoney`.
     - returns: an `NSURLSessionDataTask`.
    */
    public static func fx(base: BaseMoney, completion: Result<CounterMoney, FXError> -> Void) -> NSURLSessionDataTask {
        return quote(base) { completion($0.map { $0.counter }) }
    }
}

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

/**
 A trivial generic class suitable for subclassing for FX remote providers.
 It automatically sets up the typealias for MoneyPairType.
*/
public class FXRemoteProvider<B: MoneyType, T: MoneyType> {
    public typealias BaseMoney = B
    public typealias CounterMoney = T
}

// MARK: - ValueCoding

/**
 A CodingType which codes FXQuote
*/
public final class FXQuoteCoder: NSObject, NSCoding, CodingType {
    enum Keys: String {
        case Rate = "rate"
        case Percentage = "percentage"
    }

    /// The value being encoded or decoded
    public let value: FXQuote

    /// Initialized with an FXQuote
    public required init(_ v: FXQuote) {
        value = v
    }

    public init?(coder aDecoder: NSCoder) {
        let rate = BankersDecimal.decode(aDecoder.decodeObjectForKey(Keys.Rate.rawValue))
        let percentage = BankersDecimal.decode(aDecoder.decodeObjectForKey(Keys.Percentage.rawValue))
        value = FXQuote(rate: rate!, percentage: percentage!)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.rate.encoded, forKey: Keys.Rate.rawValue)
        aCoder.encodeObject(value.percentage.encoded, forKey: Keys.Percentage.rawValue)
    }
}


private enum FXTransactionCoderKeys: String {
    case Base = "base"
    case Commission = "commission"
    case Rate = "rate"
    case Counter = "counter"
}

/**
 A CodingType which codes FXTransaction
*/
public final class FXTransactionCoder<Base, Counter where
    Base: MoneyType,
    Base.Coder: NSCoding,
    Base.Coder.ValueType == Base,
    Base.DecimalStorageType == BankersDecimal.DecimalStorageType,
    Counter: MoneyType,
    Counter.Coder: NSCoding,
    Counter.Coder.ValueType == Counter,
    Counter.DecimalStorageType == BankersDecimal.DecimalStorageType>: NSObject, NSCoding, CodingType {

    /// The value being encoded or decoded
    public let value: FXTransaction<Base, Counter>

    /// Initialized with an FXTransaction
    public required init(_ v: FXTransaction<Base, Counter>) {
        value = v
    }

    public init?(coder aDecoder: NSCoder) {
        let base: Base? = Base.decode(aDecoder.decodeObjectForKey(FXTransactionCoderKeys.Base.rawValue))
        let rate = BankersDecimal.decode(aDecoder.decodeObjectForKey(FXTransactionCoderKeys.Rate.rawValue))
        let commission = Base.decode(aDecoder.decodeObjectForKey(FXTransactionCoderKeys.Commission.rawValue))
        let counter = Counter.decode(aDecoder.decodeObjectForKey(FXTransactionCoderKeys.Counter.rawValue))
        value = FXTransaction(base: base!, commission: commission!, rate: rate!, counter: counter!)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.base.encoded, forKey: FXTransactionCoderKeys.Base.rawValue)
        aCoder.encodeObject(value.rate.encoded, forKey: FXTransactionCoderKeys.Rate.rawValue)
        aCoder.encodeObject(value.commission.encoded, forKey: FXTransactionCoderKeys.Commission.rawValue)
        aCoder.encodeObject(value.counter.encoded, forKey: FXTransactionCoderKeys.Counter.rawValue)
    }
}


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

