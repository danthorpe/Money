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

protocol FXQuoteType {
    var ticker: String { get }
    var rate: BankersDecimal { get }
    var date: NSDate { get }
}

// MARK: - Protocol: Transaction Type

protocol FXTransactionType {
    typealias Money: MoneyType
    var money: Money { get }

    init(money: Money)
}

/**
 # FX Provider
 `FXProviderType` defines the interface for a FX
 provider.

 In addition to FX exchanges, a provide will have its 
 own characteristics, such as a name and fee structure.
*/
protocol FXProviderType {

    typealias RequestType
    typealias QuoteType: FXQuoteType

    /// The name of the provider.
    static var name: String { get }

    static var URLSession: NSURLSession { get }

    static func requestForBaseCurrencyCode(base: String, symbol: String) -> NSURLRequest

    static func exchangeRateFromResponseData(data: NSData) -> Result<QuoteType, FX.Error>
}

// MARK: - MoneyType

extension MoneyType where DecimalStorageType == BankersDecimal.DecimalStorageType {

    func convertWithRate<Other: MoneyType where Other.DecimalStorageType == DecimalStorageType>(rate: BankersDecimal) -> Other {
        return multiplyBy(Other(storage: rate.storage), withBehaviors: Other.DecimalNumberBehavior.decimalNumberBehaviors)
    }

    func exchange<T: FXTransactionType, Provider: FXProviderType where T.Money.DecimalStorageType == DecimalStorageType, Provider.RequestType == NSURLSessionDataTask>(completion: Result<T, FX.Error> -> Void) -> Provider.RequestType {
        let client = FXServiceProviderNetworkClient(session: Provider.URLSession)
        let request = Provider.requestForBaseCurrencyCode(Currency.code, symbol: T.Money.Currency.code)
        return client.get(request, adaptor: Provider.exchangeRateFromResponseData) { result in
            return result.map { T(money: self.convertWithRate($0.rate)) }
        }
    }
}


// MARK: - FX Types

struct FXQuote: FXQuoteType {
    let ticker: String
    let rate: BankersDecimal
    let date: NSDate
}

struct FXTransaction<M: MoneyType>: FXTransactionType {
    let money: M

    init(money: M) {
        self.money = money
    }
}

// MARK: - FX Providers

struct FX {

    enum Error: ErrorType {
        case ReceivedNetworkError(ErrorType?)
        case InvalidResponseDataFromProvider(String)
        case FXTickerNotFoundInResponse(String)
        case FXRateNotFoundInResponse(String)
        case FXDateNotFoundInResponse(String)
    }
}

// MARK: - FX Network Client

internal class FXServiceProviderNetworkClient<Session: NSURLSession> {
    let session: NSURLSession

    init(session: NSURLSession = NSURLSession.sharedSession()) {
        self.session = session
    }

    func get<Quote: FXQuoteType>(request: NSURLRequest, adaptor: NSData -> Result<Quote, FX.Error>, completion: Result<Quote, FX.Error> -> Void) -> NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard let data = data else {
                completion(Result(error: .ReceivedNetworkError(error)))
                return
            }
            completion(adaptor(data))
        }
        task.resume()
        return task
    }
}


// MARK: - FX Service Providers

extension FX {

    // MARK: - Yahoo

    struct Yahoo: FXProviderType {

        typealias RequestType = NSURLSessionDataTask
        typealias QuoteType = FXQuote

        static var URLSession: NSURLSession {
            return NSURLSession.sharedSession()
        }

        static let name = "Yahoo"

        static func requestForBaseCurrencyCode(base: String, symbol: String) -> NSURLRequest {
            return NSURLRequest(URL: NSURL(string: "http://download.finance.yahoo.com/d/quotes.csv?s=\(base)\(symbol)=X&f=nl1d1t1")!)
        }

        static func exchangeRateFromResponseData(data: NSData) -> Result<QuoteType, FX.Error> {
            guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
                return Result(error: FX.Error.InvalidResponseDataFromProvider(name))
            }

            let components = str.componentsSeparatedByString(",")

            if components.endIndex == 0 {
                return Result(error: FX.Error.FXTickerNotFoundInResponse(str))
            }

            let ticker = components[0].stringByReplacingOccurrencesOfString("/", withString: "")

            guard components.endIndex >= 1, let rate = Double(components[1]) else {
                return Result(error: FX.Error.FXRateNotFoundInResponse(str))
            }

            return Result(value: FXQuote(ticker: ticker, rate: BankersDecimal(floatLiteral: rate), date: NSDate()))
        }
    }
}


