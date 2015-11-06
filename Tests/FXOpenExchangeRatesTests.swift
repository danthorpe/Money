//
//  FXOpenExchangeRatesTests.swift
//  Money
//
//  Created by Daniel Thorpe on 04/11/2015.
//
//

import XCTest
import Result
import DVR
import SwiftyJSON
@testable import Money

struct MyOpenExchangeRatesAppID: OpenExchangeRatesAppID {
    static let app_id = "this_is_not_the_app_id_youre_looking_for"
}

class OpenExchangeRates<Base: MoneyType, Counter: MoneyType>: _OpenExchangeRates<Base, Counter, MyOpenExchangeRatesAppID> { }

class FreeOpenExchangeRates<Counter: MoneyType>: _ForeverFreeOpenExchangeRates<Counter, MyOpenExchangeRatesAppID> { }

class FXPaidOpenExchangeRatesTests: FXProviderTests {
    typealias Provider = OpenExchangeRates<GBP,JPY>

    func test__name() {
        XCTAssertEqual(Provider.name(), "OpenExchangeRates.org GBPJPY")
    }

    func test__base_currency() {
        XCTAssertEqual(Provider.BaseMoney.Currency.code, Currency.GBP.code)
    }

    func test__request__url_does_contain_base() {
        guard let url = Provider.request().URL else {
            XCTFail("Request did not return a URL")
            return
        }

        XCTAssertTrue(url.absoluteString.containsString("&base=GBP"))
    }
}

class FXFreeOpenExchangeRatesTests: FXProviderTests {

    typealias Provider = FreeOpenExchangeRates<EUR>
    typealias TestableProvider = TestableFXRemoteProvider<Provider>
    typealias FaultyProvider = FaultyFXRemoteProvider<Provider>

    func test__name() {
        XCTAssertEqual(Provider.name(), "OpenExchangeRates.org USDEUR")
    }

    func test__session() {
        XCTAssertEqual(Provider.session(), NSURLSession.sharedSession())
    }

    func test__base_currency() {
        XCTAssertEqual(Provider.BaseMoney.Currency.code, Currency.USD.code)
    }

    func test__request__url_does_not_contain_base() {
        guard let url = Provider.request().URL else {
            XCTFail("Request did not return a URL")
            return
        }

        XCTAssertFalse(url.absoluteString.containsString("&base="))
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
        var json = dvrJSONFromCassette(Provider.name())!
        var rates: Dictionary<String, JSON> = json["rates"].dictionary!
        rates.removeValueForKey("EUR")
        json["rates"] = JSON(rates)
        let data = try! json.rawData()
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
                XCTAssertEqual(usd, 92.09)
            }
            else {
                XCTFail("Received error: \(result.error!).")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
