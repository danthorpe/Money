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
	
	func test__money_multiplation_by_decimals() {
		money = 10
		let a: Decimal = 3.5
		let b: Decimal = 2.5
		let result = a * money * b
		XCTAssertEqual(result, 87.5)
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
	
	func test__iso_multiplation_by_decimals() {
		gbp = 10
		let a: Decimal = 3.5
		let b: Decimal = 2.5
		let result = a * gbp * b
		XCTAssertEqual(result, 87.5)
	}
}
