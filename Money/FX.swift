//
//  FX.swift
//  Money
//
//  Created by Daniel Thorpe on 02/11/2015.
//
//

import Foundation
import Result

// MARK: - Protocol: Quote Type

public protocol FXQuoteType {
    var ticker: String { get }
    var rate: BankersDecimal { get }
    var date: NSDate { get }
}

/**
 # FX Provider
 `FXProviderType` defines the interface for a FX
 provider.

 In addition to FX exchanges, a provide will have its 
 own characteristics, such as a name and fee structure.
*/
public protocol FXProviderType {

    typealias RequestType
    typealias QuoteType: FXQuoteType

    /// The name of the provider.
    static var name: String { get }

    /// The NSURL Session to use
    static var URLSession: NSURLSession { get }

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
    static func requestForBaseCurrencyCode(base: String, symbol: String) -> NSURLRequest

    /**
     Parse the received NSData into the providers own QuoteType. More 
     than likely, this will just be `FXQuote`, but providers may 
     support fees/commission info which needs representing.

     - parameter data: the `NSData` received from the service provider
     - returns: a `Result` generic over the `QuoteType` and `FX.Error` which
     supports general errors for mal-formed or missing information.
    */
    static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<QuoteType, FX.Error>
}

// MARK: - Protocol: Transaction Type

public protocol FXTransactionType {
    typealias Provider: FXProviderType
    typealias Money: MoneyType

    var money: Money { get }

    init(money: Money)
}

// MARK: - MoneyType

extension MoneyType where DecimalStorageType == BankersDecimal.DecimalStorageType {

    func convertWithRate<Other: MoneyType where Other.DecimalStorageType == DecimalStorageType>(rate: BankersDecimal) -> Other {
        return multiplyBy(Other(storage: rate.storage), withBehaviors: Other.DecimalNumberBehavior.decimalNumberBehaviors)
    }

    func exchange<T: FXTransactionType where T.Money.DecimalStorageType == DecimalStorageType, T.Provider.RequestType == NSURLSessionDataTask>(completion: Result<T, FX.Error> -> Void) -> T.Provider.RequestType {
        let client = FXServiceProviderNetworkClient(session: T.Provider.URLSession)
        let request = T.Provider.requestForBaseCurrencyCode(Currency.code, symbol: T.Money.Currency.code)
        return client.get(request, adaptor: T.Provider.quoteFromNetworkResult) { result in
            completion(result.map { T(money: self.convertWithRate($0.rate)) })
        }
    }
}


// MARK: - FX Types

public struct FXQuote: FXQuoteType {
    public let ticker: String
    public let rate: BankersDecimal
    public let date: NSDate
}

public struct FXTransaction<P: FXProviderType, M: MoneyType>: FXTransactionType {
    public typealias Provider = P
    public typealias Money = M

    public let money: M

    public init(money: M) {
        self.money = money
    }
}

// MARK: - FX Providers

public struct FX {

    public enum Error: ErrorType, Equatable {
        case NetworkError(NSError)
        case NoData
        case InvalidData(NSData)
        case RateNotFound(String)
    }
}

// MARK: - FX Network Client

internal class FXServiceProviderNetworkClient {
    let session: NSURLSession

    init(session: NSURLSession = NSURLSession.sharedSession()) {
        self.session = session
    }

    func get<Quote: FXQuoteType>(request: NSURLRequest, adaptor: Result<(NSData?, NSURLResponse?), NSError> -> Result<Quote, FX.Error>, completion: Result<Quote, FX.Error> -> Void) -> NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            let result = error.map { Result(error: $0) } ?? Result(value: (data, response))
            completion(adaptor(result))
        }
        task.resume()
        return task
    }
}


// MARK: - FX Service Providers

extension FX {

    // MARK: - Yahoo

    public struct Yahoo: FXProviderType {

        public typealias RequestType = NSURLSessionDataTask
        public typealias QuoteType = FXQuote

        public static var URLSession: NSURLSession {
            return NSURLSession.sharedSession()
        }

        public static let name = "Yahoo"

        public static func requestForBaseCurrencyCode(base: String, symbol: String) -> NSURLRequest {
            return NSURLRequest(URL: NSURL(string: "http://download.finance.yahoo.com/d/quotes.csv?s=\(base)\(symbol)=X&f=nl1d1t1")!)
        }

        public static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<QuoteType, FX.Error> {
            return result.analysis(

                ifSuccess: { data, response in

                    guard let data = data else {
                        return Result(error: FX.Error.NoData)
                    }

                    guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
                        return Result(error: FX.Error.InvalidData(data))
                    }

                    let components = str.componentsSeparatedByString(",")

                    if components.count < 4 {
                        return Result(error: FX.Error.InvalidData(data))
                    }

                    let ticker = components[0].stringByReplacingOccurrencesOfString("/", withString: "")

                    guard let rate = Double(components[1]) else {
                        return Result(error: FX.Error.RateNotFound(str))
                    }
                    
                    return Result(value: FXQuote(ticker: ticker, rate: BankersDecimal(floatLiteral: rate), date: NSDate()))

                },

                ifFailure: { error in
                    return Result(error: FX.Error.NetworkError(error))
                }
            )
        }
    }
}

public func ==(lhs: FX.Error, rhs: FX.Error) -> Bool {
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

