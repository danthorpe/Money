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

    func test__Given_initialized_with_no_argument__Then_money_is_zero() {
        money = Money()
        XCTAssertEqual(money, .makeZero())
        XCTAssertEqual(money, 0)
    }

    func test__Given_initialized_with_no_argument__Then_gbp_is_zero() {
        gbp = GBP()
        XCTAssertEqual(gbp, 0)
    }

    func test__Given_initialized_with_one__Then_gbp_is_one() {
        gbp = GBP(integerLiteral: 1)
        XCTAssertEqual(gbp, 1)
    }

    func test__Given_initialized_with_double__Then_gbp_is_one() {
        gbp = GBP(floatLiteral: 10.0)
        XCTAssertEqual(gbp, 10.0)
    }

}

extension MoneyTestCase {

    func test__money_multiplation() {
        money = 10
        let result = money * Money(decimal: Decimal(integerLiteral: 10))
        XCTAssertEqual(result, 100)
    }

    func test__money_multiplation_by_integer_literals() {
        money = 10
        let result = 3 * money * 2
        XCTAssertEqual(result, 60)
    }

    func test__money_multiplation_by_float_literals() {
        money = 10
        let result = 3.5 * money * 2.5
        XCTAssertEqual(result, 87.5)
    }
}

extension MoneyTestCase {

    func test__money_addition() {
        money = 10
        let result = money + Money(decimal: Decimal(integerLiteral: 10))
        XCTAssertEqual(result, 20)
    }

    func test__money_addition_by_integer_literals() {
        money = 10
        let result = 3 + money + 2
        XCTAssertEqual(result, 15)
    }

    func test__money_addition_by_float_literals() {
        money = 10
        let result = 3.5 + money + 2.5
        XCTAssertEqual(result, 16)
    }
}

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

    func test__iso_multiplation() {
        gbp = 10
        let result = gbp * GBP(decimal: Decimal(integerLiteral: 10))
        XCTAssertEqual(result, 100)
    }

    func test__iso_multiplation_by_integer_literals() {
        gbp = 10
        let result = 3 * gbp * 2
        XCTAssertEqual(result, 60)
    }

    func test__iso_multiplation_by_float_literals() {
        gbp = 10
        let result = 3.5 * gbp * 2.5
        XCTAssertEqual(result, 87.5)
    }
}

extension MoneyTestCase {

    func test__iso_addition() {
        gbp = 10
        let result = gbp + GBP(decimal: Decimal(integerLiteral: 10))
        XCTAssertEqual(result, 20)
    }

    func test__iso_addition_by_integer_literals() {
        gbp = 10
        let result = 3 + gbp + 2
        XCTAssertEqual(result, 15)
    }

    func test__iso_addition_by_float_literals() {
        gbp = 10
        let result = 3.5 + gbp + 2.5
        XCTAssertEqual(result, 16)
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
