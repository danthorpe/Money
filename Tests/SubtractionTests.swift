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

    func test__money_subtraction() {
        money = 10
        let result = money - Money(decimal: Decimal(integerLiteral: 10))
        XCTAssertEqual(result, 0)
    }

    func test__money_subtraction_by_integer_literals() {
        money = 10
        let result = 3 - money - 2
        XCTAssertEqual(result, -9)
    }

    func test__money_subtraction_by_float_literals() {
        money = 10
        let result = 3.5 - money - 2.5
        XCTAssertEqual(result, -9)
    }
}

extension MoneyTestCase {

    func test__iso_subtraction() {
        gbp = 10
        let result = gbp - GBP(decimal: Decimal(integerLiteral: 10))
        XCTAssertEqual(result, 0)
    }

    func test__iso_subtraction_by_integer_literals() {
        gbp = 10
        let result = 3 - gbp - 2
        XCTAssertEqual(result, -9)
    }

    func test__iso_subtraction_by_float_literals() {
        gbp = 10
        let result = 3.5 - gbp - 2.5
        XCTAssertEqual(result, -9)
    }
}
