//
//  FXTests.swift
//  Money
//
//  Created by Daniel Thorpe on 02/11/2015.
//
//

import XCTest
@testable import Money

class FakeFXProvider {
    var didGetName = false
    let quotes: [String: BankersDecimal] = [
        "GBPEUR": 1.4069,
        "GBPUSD": 1.5409,
        "GBPJPY": 186.7150,
        "EURUSD": 1.0947,
        "EURJPY": 132.6150,
        "EURGBP": 0.7103,
        "USDJPY": 121.1545,
        "USDGBP": 0.6490,
        "USDEUR": 0.9135,
        "JPYGBP": 0.0054,
        "JPYEUR": 0.0075,
        "JPYUSD": 0.0083
    ]

    var didGetQuoteForTicker: String? = .None
}

extension FakeFXProvider: FXProviderType {
    typealias RequestType = Void

    var name: String {
        get {
            didGetName = true
            return "Fake FX Provider"
        }
    }

    func quote(ticker: String, completion: FXQuote -> Void) -> Void {
        didGetQuoteForTicker = ticker
        completion(FXQuote(ticker: ticker, rate: quotes[ticker]!, date: NSDate()))
    }
}


class FXProviderTypeTests: XCTestCase {

    var provider: FakeFXProvider!
    var gbp: GBP!
    var eur: EUR!
    var usd: USD!
    var jpy: JPY!

    override func setUp() {
        super.setUp()
        provider = FakeFXProvider()
        gbp = 139
        eur = 166.67
        usd = 199.99
        jpy = 34_567
    }

    override func tearDown() {
        provider = nil
        gbp = nil
        usd = nil
        eur = nil
        jpy = nil
        super.tearDown()
    }

    func test__exhange_gbp_to_eur() {
        provider.exchange(gbp) { (result: FXResult<EUR>) in
            XCTAssertEqual(result.money, 195.56)
        }
        XCTAssertEqual(provider.didGetQuoteForTicker!, "GBPEUR")
    }

    func test__exhange_gbp_to_usd() {
        provider.exchange(gbp) { (result: FXResult<USD>) in
            XCTAssertEqual(result.money, 214.19)
        }
        XCTAssertEqual(provider.didGetQuoteForTicker!, "GBPUSD")
    }

    func test__exhange_gbp_to_jpy() {
        provider.exchange(gbp) { (result: FXResult<JPY>) in
            XCTAssertEqual(result.money, 25_953)
        }
        XCTAssertEqual(provider.didGetQuoteForTicker!, "GBPJPY")
    }

    func test__exhange_eur_to_usd() {
        eur.exchange(provider) { (result: FXResult<USD>) in
            XCTAssertEqual(result.money, 182.45)
        }
        XCTAssertEqual(provider.didGetQuoteForTicker!, "EURUSD")
    }

    func test__exhange_eur_to_jpy() {
        eur.exchange(provider) { (result: FXResult<JPY>) in
            XCTAssertEqual(result.money, 22_103)
        }
        XCTAssertEqual(provider.didGetQuoteForTicker!, "EURJPY")
    }

    func test__exhange_eur_to_gbp() {
        eur.exchange(provider) { (result: FXResult<GBP>) in
            XCTAssertEqual(result.money, 118.39)
        }
        XCTAssertEqual(provider.didGetQuoteForTicker!, "EURGBP")
    }

    func test__exhange_usd_to_jpy() {
        usd.exchange(provider) { (result: JPY) in
            XCTAssertEqual(result, 24_230)
        }
        XCTAssertEqual(provider.didGetQuoteForTicker!, "USDJPY")
    }

    func test__exhange_usd_to_gbp() {
        usd.exchange(provider) { (result: GBP) in
            XCTAssertEqual(result, 129.79)
        }
        XCTAssertEqual(provider.didGetQuoteForTicker!, "USDGBP")
    }

    func test__exhange_usd_to_eur() {
        usd.exchange(provider) { (result: EUR) in
            XCTAssertEqual(result, 182.69)
        }
        XCTAssertEqual(provider.didGetQuoteForTicker!, "USDEUR")
    }
}