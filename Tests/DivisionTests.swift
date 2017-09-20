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

    func test__money_division() {
        money = 10
        let result = money / Money(decimal: Decimal(floatLiteral: 2))
        XCTAssertEqual(result, 5)
    }

    func test__money_division_by_integer_literals() {
        money = 10
        let result = 3 / money / 2
        XCTAssertEqual(result, 0.15)
    }

    func test__money_division_by_float_literals() {
        money = 10
        let result = 3.5 / money / 2.5
        XCTAssertEqual(result.floatValue, 0.14, accuracy: 0.001)
    }
}



