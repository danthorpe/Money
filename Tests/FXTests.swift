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

class TestFXProvider<Provider: FXProviderType>: FXProviderType {

    typealias RequestType = Provider.RequestType
    typealias QuoteType = Provider.QuoteType

    static var URLSession: NSURLSession {
        return Sessions.sessionWithCassetteName(name)
    }

    static var name: String {
        return Provider.name
    }

    static func requestForBaseCurrencyCode(base: String, symbol: String) -> NSURLRequest {
        return Provider.requestForBaseCurrencyCode(base, symbol: symbol)
    }

    static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<QuoteType, FX.Error> {
        return Provider.quoteFromNetworkResult(result)
    }
}

extension FX {
    struct Test {
        typealias Yahoo = TestFXProvider<FX.Yahoo>
    }
}

class FXErrorTests: XCTestCase {

    func test__fx_error__equality() {
        XCTAssertNotEqual(FX.Error.NoData, FX.Error.RateNotFound("whatever"))
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

    func test__name() {
        XCTAssertEqual(FX.Yahoo.name, "Yahoo")
    }

    func test__session() {
        XCTAssertEqual(FX.Yahoo.URLSession, NSURLSession.sharedSession())
    }

    func test__quote_adaptor__with_network_error() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLError.BadServerResponse.rawValue, userInfo: nil)
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(error: error)
        let quote = FX.Yahoo.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FX.Error.NetworkError(error))
    }

    func test__quote_adaptor__with_no_data() {
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (.None, .None))
        let quote = FX.Yahoo.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FX.Error.NoData)
    }

    func test__quote_adaptor__with_garbage_data() {
        let data = createGarbageData()
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (data, .None))
        let quote = FX.Yahoo.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FX.Error.InvalidData(data))
    }

    func test__quote_adaptor__with_incorrect_text_response() {
        let text = "This isn't a correct response"
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (data, .None))
        let quote = FX.Yahoo.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FX.Error.InvalidData(data!))
    }

    func test__quote_adaptor__with_missing_rate() {
        let text = "This,could be,a correct,response"
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)
        let network: Result<(NSData?, NSURLResponse?), NSError> = Result(value: (data, .None))
        let quote = FX.Yahoo.quoteFromNetworkResult(network)
        XCTAssertEqual(quote.error!, FX.Error.RateNotFound(text))
    }


    func test__exhange_gbp_to_eur() {
        let gbp: GBP = 100
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")
        gbp.exchange { (result: Result<FXTransaction<FX.Test.Yahoo, EUR>, FX.Error>) in
            XCTAssertEqual(result.value!.money, 141.22)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}