//
// Money
// File created on 24/09/2017.
// 	
// Copyright (c) 2015-2017 Daniel Thorpe
// 
// Money is licensed under the MIT License. Read the full license at 
// https://github.com/danthorpe/Money/blob/master/LICENSE
//

import XCTest

@testable import Money

extension MoneyTestCase {

    func test__description() {
        money = 10
        #if os(OSX)
        let result: String = money.formatted(forLocaleId: "en_GB")
        XCTAssertEqual(result, "£10.00")
        #elseif os(iOS)
        let result: String = money.formatted(forLocaleId: "en_US")
        XCTAssertEqual(result, "$10.00")
        #endif
    }

    func test__description_float() {
        money = 10.12
        #if os(OSX)
            let result: String = money.formatted(forLocaleId: "en_GB")
            XCTAssertEqual(result, "£10.12")
        #elseif os(iOS)
            let result: String = money.formatted(forLocaleId: "en_US")
            XCTAssertEqual(result, "$10.12")
        #endif
    }
}

extension MoneyTestCase {

    func test__iso_description() {
        gbp = 10
        let result: String = gbp.formatted(forLocaleId: "en_GB")
        XCTAssertEqual(result, "£10.00")
    }

    #if os(iOS)
    func test__iso_description_spain() {
        gbp = 10
        let result: String = gbp.formatted(forLocaleId: "es_ES")
        // Note that for Spanish from Spain, the decimal point indicator is a comma,
        // and the currency symbol is placed after the numbers.
        XCTAssertEqual(result, "10,00 £")
    }
    #endif
}
