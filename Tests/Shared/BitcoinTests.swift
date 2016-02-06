//
//  BitcoinTests.swift
//  Money
//
//  Created by Daniel Thorpe on 08/11/2015.
//
//

import XCTest
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

