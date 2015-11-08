//
//  BitcoinTests.swift
//  Money
//
//  Created by Daniel Thorpe on 08/11/2015.
//
//

import XCTest
import Result
import DVR
import SwiftyJSON
@testable import Money


class BitcoinCurrencyTests: XCTestCase {

    func test__xbt_currency_code() {
        XCTAssertEqual(Currency.XBT.code, "XBT")
    }

    func test__btc_currency_code() {
        XCTAssertEqual(Currency.BTC.code, "BTC")
    }

    func test__btc_currency_symbol() {
        XCTAssertEqual(Currency.BTC.symbol, "Ƀ")
    }

    func test__btc_currency_scale() {
        XCTAssertEqual(Currency.BTC.scale, 8)
    }
}

class CEXTests: XCTestCase {

    func test__usd_commission_percentage() {
        XCTAssertEqual(Currency.USD.cex_commissionPercentage, 0.2)
    }

    func test__eur_commission_percentage() {
        XCTAssertEqual(Currency.EUR.cex_commissionPercentage, 0.2)
    }

    func test__rub_commission_percentage() {
        XCTAssertEqual(Currency.RUB.cex_commissionPercentage, 0)
    }
}

class FXCEXBuyTests: FXProviderTests {

    typealias Provider = CEXBuy<USD>
    typealias TestableProvider = TestableFXRemoteProvider<Provider>
    typealias FaultyProvider = FaultyFXRemoteProvider<Provider>

    func test__name() {
        XCTAssertEqual(Provider.name(), "CEX.IO USDBTC")
    }

    func test__session() {
        XCTAssertEqual(Provider.session(), NSURLSession.sharedSession())
    }

    func test__quote_adaptor__with_network_error() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLError.BadServerResponse.rawValue, userInfo: nil)
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(error: error)
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.NetworkError(error))
    }

    func test__quote_adaptor__with_no_data() {
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (.None, .None))
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.NoData)
    }

    func test__quote_adaptor__with_garbage_data() {
        let data = createGarbageData()
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (data, .None))
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.InvalidData(data))
    }

    func test__quote_adaptor__with_missing_rate() {
        let json = dvrJSONFromCassette(Provider.name())!
        var dic = json.dictionaryValue
        dic["amount"] = json["amnt"]
        dic.removeValueForKey("amnt")
        let data = try! JSON(dic).rawData()
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (data, .None))
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.RateNotFound(Provider.name()))
    }

    func test__faulty_provider() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        FaultyProvider.fx(100) { result in
            guard let error = result.error else {
                XCTFail("Should have received a network error.")
                return
            }
            switch error {
            case .NetworkError(_):
                break // This is the success path.
            default:
                XCTFail("Returned \(error), should be a .NetworkError")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func test__fx() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        TestableProvider.fx(100) { result in
            if let usd = result.value {
                XCTAssertEqual(usd, 0.25470294)
            }
            else {
                XCTFail("Received error: \(result.error!).")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

}

class FXCEXSellTests: FXProviderTests {

    typealias Provider = CEXSell<USD>
    typealias TestableProvider = TestableFXRemoteProvider<Provider>
    typealias FaultyProvider = FaultyFXRemoteProvider<Provider>

    func test__name() {
        XCTAssertEqual(Provider.name(), "CEX.IO BTCUSD")
    }

    func test__session() {
        XCTAssertEqual(Provider.session(), NSURLSession.sharedSession())
    }

    func test__quote_adaptor__with_network_error() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLError.BadServerResponse.rawValue, userInfo: nil)
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(error: error)
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.NetworkError(error))
    }

    func test__quote_adaptor__with_no_data() {
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (.None, .None))
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.NoData)
    }

    func test__quote_adaptor__with_garbage_data() {
        let data = createGarbageData()
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (data, .None))
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.InvalidData(data))
    }

    func test__quote_adaptor__with_missing_rate() {
        let json = dvrJSONFromCassette(Provider.name())!
        var dic = json.dictionaryValue
        dic["amount"] = json["amnt"]
        dic.removeValueForKey("amnt")
        let data = try! JSON(dic).rawData()
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (data, .None))
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.RateNotFound(Provider.name()))
    }

    func test__faulty_provider() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        FaultyProvider.fx(100) { result in
            guard let error = result.error else {
                XCTFail("Should have received a network error.")
                return
            }
            switch error {
            case .NetworkError(_):
                break // This is the success path.
            default:
                XCTFail("Returned \(error), should be a .NetworkError")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func test__fx() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        TestableProvider.fx(100) { result in
            if let btc = result.value {
                XCTAssertEqual(btc, 39_198.35)
            }
            else {
                XCTFail("Received error: \(result.error!).")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
}

}

