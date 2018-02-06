//
// Money
// File created on 15/09/2017.
// 	
// Copyright (c) 2015-2017 Daniel Thorpe
// 
// Money is licensed under the MIT License. Read the full license at 
// https://github.com/danthorpe/Money/blob/master/LICENSE
//

import XCTest

@testable import Money

extension MoneyTestCase {

    func test__less_than() {
        money = 10
        XCTAssertLessThan(money, 11)
    }

    func test__greater_than() {
        money = 10
        XCTAssertGreaterThan(money, 9)
    }
}

extension MoneyTestCase {

    func test__iso_less_than() {
        gbp = 10
        XCTAssertLessThan(gbp, 11)
    }

    func test__iso_greater_than() {
        gbp = 10
        XCTAssertGreaterThan(gbp, 9)
    }
}
