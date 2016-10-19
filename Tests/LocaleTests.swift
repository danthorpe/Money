//
// Money, https://github.com/danthorpe/Money
// Created by Dan Thorpe, @danthorpe
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Daniel Thorpe
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
@testable import Money

class LocaleTests: XCTestCase {

    var en_US: NSLocale!
    var es_ES: NSLocale!

    override func setUp() {
        super.setUp()
        en_US = NSLocale(localeIdentifier: MNYLocale.English(.UnitedStates).localeIdentifier)
        es_ES = NSLocale(localeIdentifier: MNYLocale.Spanish(.Spain).localeIdentifier)
    }

    override func tearDown() {
        en_US = nil
        es_ES = nil
        super.tearDown()
    }

    func test__currency_code() {
        XCTAssertEqual(en_US.mny_currencyCode, "USD")
        XCTAssertEqual(es_ES.mny_currencyCode, "EUR")
    }

    func test__currency_symbol() {
        XCTAssertEqual(en_US.mny_currencySymbol, "$")
        XCTAssertEqual(es_ES.mny_currencySymbol, "€")
    }

    func test__currency_currencyGroupingSeparator() {
        XCTAssertEqual(en_US.mny_currencyGroupingSeparator, ",")
        XCTAssertEqual(es_ES.mny_currencyGroupingSeparator, ".")
    }

    func test__currency_currencyDecimalSeparator() {
        XCTAssertEqual(en_US.mny_currencyDecimalSeparator, ".")
        XCTAssertEqual(es_ES.mny_currencyDecimalSeparator, ",")
    }
}

