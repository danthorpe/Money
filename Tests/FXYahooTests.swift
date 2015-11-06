//
//  FXYahooTests.swift
//  Money
//
//  Created by Daniel Thorpe on 04/11/2015.
//
//

import XCTest
import Result
import DVR
@testable import Money

class FXYahooTests: FXProviderTests {

    typealias Provider = Yahoo<GBP, USD>
    typealias TestableProvider = TestableFXRemoteProvider<Provider>
    typealias FaultyProvider = FaultyFXRemoteProvider<Provider>

    func test__name() {
        XCTAssertEqual(Provider.name(), "Yahoo GBPUSD")
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

    func test__quote_adaptor__with_incorrect_text_response() {
        let text = "This isn't a correct response"
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (data, .None))
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.InvalidData(data!))
    }

    func test__quote_adaptor__with_missing_rate() {
        let text = "This,could be,a correct,response"
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (data, .None))
        let quote = Provider.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FXError.RateNotFound(text))
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
                XCTAssertEqual(usd, 152.37)
            }
            else {
                XCTFail("Received error: \(result.error!).")
            }
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}