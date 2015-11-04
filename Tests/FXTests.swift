//
//  FXTests.swift
//  Money
//
//  Created by Daniel Thorpe on 02/11/2015.
//
//

import XCTest
import Result
import DVR
@testable import Money

class Sessions {

    static func sessionWithCassetteName(name: String) -> Session {
        return sharedInstance.sessionWithCassetteName(name)
    }

    static let sharedInstance = Sessions()

    var sessions = Dictionary<String, Session>()

    func sessionWithCassetteName(name: String) -> Session {
        guard let session = sessions[name] else {
            let _session = Session(cassetteName: name)
            sessions.updateValue(_session, forKey: name)
            return _session
        }
        return session
    }
}

class TestableFXRemoteProvider<Provider: FXRemoteProviderType>: FXRemoteProviderType {

    typealias CounterMoney = Provider.CounterMoney
    typealias BaseMoney = Provider.BaseMoney

    static func name() -> String {
        return Provider.name()
    }

    static func session() -> NSURLSession {
        return Sessions.sessionWithCassetteName(name())
    }

    static func request() -> NSURLRequest {
        return Provider.request()
    }

    static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<FXQuote, FXError> {
        return Provider.quoteFromNetworkResult(result)
    }
}

class FaultyFXRemoteProvider<Provider: FXRemoteProviderType>: FXRemoteProviderType {

    typealias CounterMoney = Provider.CounterMoney
    typealias BaseMoney = Provider.BaseMoney

    static func name() -> String {
        return "\(Provider.name()).faulty"
    }

    static func session() -> NSURLSession {
        return Provider.session()
    }

    static func request() -> NSURLRequest {
        let request = Provider.request()
        if let url = request.URL,
            host = url.host,
            modified = NSURL(string: url.absoluteString.stringByReplacingOccurrencesOfString(host, withString: "broken-host.xyz")) {
                return NSURLRequest(URL: modified)
        }
        return request
    }

    static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<FXQuote, FXError> {
        return Provider.quoteFromNetworkResult(result)
    }
}

class FXErrorTests: XCTestCase {

    func test__fx_error__equality() {
        XCTAssertNotEqual(FXError.NoData, FXError.RateNotFound("whatever"))
    }
}

class FXProviderTests: XCTestCase {

    func createGarbageData() -> NSData {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("Troll", ofType: ".png")
        let data = NSData(contentsOfFile: path!)
        return data!
    }
}

class FXYahooTests: FXProviderTests {

    typealias Provider = Yahoo<GBP, USD>
    typealias TestableProvider = TestableFXRemoteProvider<Provider>
    typealias FaultyProvider = FaultyFXRemoteProvider<Yahoo<GBP, USD>>

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
        let gbp: GBP = 100
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        FaultyProvider.fx(gbp) { result in
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

    func test__exhange_gbp_to_eur() {
        let gbp: GBP = 100
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        TestableProvider.fx(gbp) { result in
            if let usd = result.value?.counter {
                XCTAssertEqual(usd, 153.89)
            }
            else {
                XCTFail("Did not receive any USDs.")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }
}


