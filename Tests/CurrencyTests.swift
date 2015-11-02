//
//  CurrencyTests.swift
//  Money
//
//  Created by Daniel Thorpe on 02/11/2015.
//
//

import XCTest
@testable import Money

class CurrencyCodeTests: XCTestCase {
    func test__GBP_code() { XCTAssertEqual(Currency.GBP.code, "GBP") }
    func test__EUR_code() { XCTAssertEqual(Currency.EUR.code, "EUR") }
    func test__USD_code() { XCTAssertEqual(Currency.USD.code, "USD") }
}

class CurrencySymbolTests: XCTestCase {
    func test__GBP_symbol() { XCTAssertEqual(Currency.GBP.symbol, "£") }
    func test__EUR_symbol() { XCTAssertEqual(Currency.EUR.symbol, "€") }
    func test__USD_symbol() { XCTAssertEqual(Currency.USD.symbol, "US$") }
    func test__CAD_symbol() { XCTAssertEqual(Currency.CAD.symbol, "CA$") }
}

