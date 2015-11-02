//
//  FX.swift
//  Money
//
//  Created by Daniel Thorpe on 02/11/2015.
//
//

import Foundation

protocol FXResultType {
    typealias Money: MoneyType
    var money: Money { get }
}

protocol FXForwardExchangeType {

    /**
     Exchange the input money into the output money.
     
     - parameter completion: A completion block which receives
     the output.
    */
    func exchangeTo<Input: MoneyType, Output: MoneyType, Result: FXResultType where Result.Money == Output>(input: Input, completion: Result -> Void)
}

protocol FXReverseExchangeType {

    /**
     Calculate the input money required to exchange into the output money.

     - parameter completion: A completion block which receives
     the necessary input money.
     */
    func exchangeFrom<Input: MoneyType, Output: MoneyType, Result: FXResultType where Result.Money == Input>(ouput: Output, completion: Result -> Void)
}

/**
 # FX Provider
 `FXProviderType` defines the interface for a FX
 provider.

 In addition to FX exchanges, a provide will have its 
 own characteristics, such as a name and fee structure.
*/
protocol FXProviderType: FXForwardExchangeType, FXReverseExchangeType {

    /// The name of the provider.
    static var name: String { get }
}

// MARK: - Providers

final class Yahoo {
    static let name = "Yahoo"

    func requestQuoteForTicker(ticker: String, completion: Double -> Void) -> NSURLSessionDataTask {
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
                    completion(rate)
                }
            }
        }
        return task
    }
}

extension Yahoo: FXProviderType {

    func exchangeTo<Input: MoneyType, Output: MoneyType, Result: FXResultType where Result.Money == Output>(input: Input, completion: Result -> Void) {

    }

    func exchangeFrom<Input: MoneyType, Output: MoneyType, Result: FXResultType where Result.Money == Input>(ouput: Output, completion: Result -> Void) {
        
    }
}





// MARK: - MoneyType Support

extension MoneyType {

    /**
     ## Forward Foreign Exchange
     Using a FX Provider, calculate how much of another `MoneyType` the receiver would 
     be exchanged into. Note that it should be assumed that the conversion is 
     determined asynchronously.
     
         let pounds: GBP = 100
         pounds.exchangeToUsing(yahoo) { (dollars: USD) in
            print("Will receive \(dollars) from \(pounds)")
         }
    */
    func exchangeToUsing<Output: MoneyType, Provider: FXProviderType, Result: FXResultType where Result.Money == Output>(provider: Provider, to: Result -> Void) {
        provider.exchangeTo(self, completion: to)
    }

    /**
     ## Reverse Foreign Exchange
     Using a FX Provider, calculate how much of another `MoneyType` is required to convert
     into the receiver. Note that it should be assumed that the conversion is
     determined asynchronously.

        let pounds: GBP = 100
        pounds.exchangeFromUsing(yahoo) { (euros: EUR) in
            print("Require \(euros) to get \(pounds)")
        }
     */
    func exchangeFromUsing<Input: MoneyType, Provider: FXProviderType, Result: FXResultType where Result.Money == Input>(provider: Provider, from: Result -> Void) {
        provider.exchangeFrom(self, completion: from)
    }
}

