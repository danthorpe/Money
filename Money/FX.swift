//
//  FX.swift
//  Money
//
//  Created by Daniel Thorpe on 02/11/2015.
//
//

import Foundation

protocol FXQuoteType {
    var ticker: String { get }
    var rate: BankersDecimal { get }
    var date: NSDate { get }
}

protocol FXResultType {
    typealias Money: MoneyType
    var money: Money { get }

    init(money: Money)
}

protocol FXExchangeType {
    typealias RequestType

    /**
     Exchange money into other money.

     - parameter completion: A completion block which receives
     the output.
     */
    func exchange<M: MoneyType, Result: FXResultType where M.DecimalStorageType == BankersDecimal.DecimalStorageType, M.DecimalStorageType == Result.Money.DecimalStorageType>(money: M, completion: Result -> Void) -> RequestType
}

/**
 # FX Provider
 `FXProviderType` defines the interface for a FX
 provider.

 In addition to FX exchanges, a provide will have its 
 own characteristics, such as a name and fee structure.
*/
protocol FXProviderType: FXExchangeType {
    typealias Quote: FXQuoteType


    /// The name of the provider.
    var name: String { get }

    func quote(ticker: String, completion: Quote -> Void) -> RequestType
}

extension FXProviderType {

    func exchange<M: MoneyType, Result: FXResultType where M.DecimalStorageType == BankersDecimal.DecimalStorageType, M.DecimalStorageType == Result.Money.DecimalStorageType>(money: M, completion: Result -> Void) -> RequestType {
        return quote("\(M.Currency.code)\(Result.Money.Currency.code)") { completion(Result(money: money.convertWithRate($0.rate))) }
    }
}

internal extension MoneyType where DecimalStorageType == BankersDecimal.DecimalStorageType {

    func convertWithRate<Other: MoneyType where Other.DecimalStorageType == DecimalStorageType>(rate: BankersDecimal) -> Other {
        return multiplyBy(Other(storage: rate.storage), withBehaviors: Other.DecimalNumberBehavior.decimalNumberBehaviors)
    }
}

// MARK: - FX Types

struct FXQuote: FXQuoteType {
    let ticker: String
    let rate: BankersDecimal
    let date: NSDate
}

struct FXResult<M: MoneyType>: FXResultType {
    let money: M

    init(money: M) {
        self.money = money
    }
}

// MARK: - FX Providers

struct Providers { }

// MARK: - Yahoo

extension Providers {

    struct Yahoo: FXProviderType {
        typealias RequestType = NSURLSessionDataTask

        let name = "Yahoo"

        func quote(ticker: String, completion: FXQuote -> Void) -> NSURLSessionDataTask {
            guard let url = NSURL(string: "http://download.finance.yahoo.com/d/quotes.csv?s=\(ticker)=X&f=nl1d1t1") else {
                fatalError("Unable to construct URL for Yahoo Finance API")
            }

            let request = NSURLRequest(URL: url)
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request) { data, response, error in
                // Result is a string like this:
                // "GBP/EUR",1.3994,"11/2/2015","4:51pm"

                // To start with, split by comma
                if let data = data, str = String(data: data, encoding: NSUTF8StringEncoding) {
                    let components = str.componentsSeparatedByString(",")
                    if components.endIndex >= 1, let rate = Double(components[1]) {
                        completion(FXQuote(ticker: ticker, rate: BankersDecimal(floatLiteral: rate), date: NSDate()))
                    }
                }
            }
            return task
        }
    }
}



