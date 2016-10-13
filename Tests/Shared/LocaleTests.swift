//
//  LocaleTests.swift
//  Money
//
//  Created by Daniel Thorpe on 23/11/2015.
//
//

import XCTest
@testable import Money

class LocaleTests: XCTestCase {

    var en_US: Locale!
    var es_ES: Locale!

    override func setUp() {
        super.setUp()
        en_US = Locale(identifier: Localization.English(.UnitedStates).localeIdentifier)
        es_ES = Locale(identifier: Localization.Spanish(.Spain).localeIdentifier)
    }

    override func tearDown() {
        en_US = nil
        es_ES = nil
        super.tearDown()
    }

    func test__currency_code() {
        XCTAssertEqual(en_US.money_currencyCode, "USD")
        XCTAssertEqual(es_ES.money_currencyCode, "EUR")
    }

    func test__currency_symbol() {
        XCTAssertEqual(en_US.money_currencySymbol, "$")
        XCTAssertEqual(es_ES.money_currencySymbol, "€")
    }

    func test__currency_currencyGroupingSeparator() {
        XCTAssertEqual(en_US.currencyGroupingSeparator, ",")
        XCTAssertEqual(es_ES.currencyGroupingSeparator, ".")
    }

    func test__currency_currencyDecimalSeparator() {
        XCTAssertEqual(en_US.currencyDecimalSeparator, ".")
        XCTAssertEqual(es_ES.currencyDecimalSeparator, ",")
    }
}

