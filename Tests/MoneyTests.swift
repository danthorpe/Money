//
//  Money_iOSTests.swift
//  Money-iOSTests
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import XCTest
@testable import Money

class MoneyInitializerTests: XCTestCase {

    var money: Cash!

    func test__money_initialize_with__nothing() {
        money = Cash()
        XCTAssertEqual(money.value, NSDecimalNumber.zero())
    }

    func test__money_initialize_with__float() {
        money = 6.66
        XCTAssertEqual(money.value, NSDecimalNumber(floatLiteral: 6.66))
    }

    func test__money_initialize_with__int_0() {
        money = 0
        XCTAssertEqual(money.value, NSDecimalNumber.zero())
    }

    func test__money_initialize_with__int_1() {
        money = 1
        XCTAssertEqual(money.value, NSDecimalNumber.one())
    }

    func test__money_initialize_with__int_other() {
        money = 666
        XCTAssertEqual(money.value, NSDecimalNumber(integerLiteral: 666))
    }
}

class MoneyEqualityTests: XCTestCase {
    var aMoney: Cash!
    var bMoney: Cash!

    func test__money_equals_money() {
        aMoney = 6.66
        bMoney = 6.66
        XCTAssertEqual(aMoney, bMoney)
    }

    func test__money_does_not_equal_money() {
        aMoney = 6.66
        bMoney = 5.66
        XCTAssertNotEqual(aMoney, bMoney)
    }
}

class MoneyComparableTests: XCTestCase {

    func test__money_sorts() {
        let monies: [Cash] = [ 0, 12, 4.50, 9.99, 99, 9.99, 2.49, 16.69]
        let sorted = monies.sort()
        XCTAssertEqual(sorted, [0, 2.49, 4.50, 9.99, 9.99, 12, 16.69, 99])
    }
}

class MoneySignedNumberTests: XCTestCase {

    func test__money_negates() {
        let money: Cash = 16.49
        let modified = -money
        XCTAssertEqual(modified, Cash(floatLiteral: -16.49))
    }

    func test__money_subtracts() {
        let a: Cash = 16.49
        let b: Cash = 6.49
        let result = a - b
        XCTAssertEqual(result, Cash(integerLiteral: 10))
    }
}

class MoneyAddingTests: XCTestCase {

    var a: Cash!
    var b: Cash!

    func test__addition_1() {
        a = 0
        b = 0.5
        XCTAssertEqual(a + b, 0.5)
    }

    func test__addition_2() {
        a = 0.99
        b = 0.01
        XCTAssertEqual(a + b, 1)
    }

    func test__addition_3() {
        a = 0.999
        b = 0.011
        XCTAssertEqual(a + b, 1.01)
    }

    func test__addition_4() {
        a = 20_000_000.000
        b = 20_000_000.99
        XCTAssertEqual(a + b, 40_000_000.99)
    }
}

class MoneyRemainderTests: XCTestCase {
    var dividend: Cash!
    var divisor: Cash!

    func test__remainer_all_positive() {
        dividend = 37.50
        divisor = 5
        XCTAssertEqual(dividend % divisor, 2.50)
    }

    func test__remainer_all_negative() {
        dividend = -37.50
        divisor = -5
        XCTAssertEqual(dividend % divisor, 2.50)
    }

    func test__remainer_negative_divisor() {
        dividend = 37.50
        divisor = -5
        XCTAssertEqual(dividend % divisor, 2.50)
    }

    func test__remainer_negative_dividend() {
        dividend = -37.50
        divisor = 5
        XCTAssertEqual(dividend % divisor, 2.50)
    }
}

class MoneyMultiplicationTests: XCTestCase {
    var money: Cash!
    var result: Cash!

    override func setUp() {
        super.setUp()
        money = 9.99
    }

    override func tearDown() {
        money = nil
        result = nil
        super.tearDown()
    }

    func test__multiplication_int_0() {
        result = money * 0
        XCTAssertEqual(result, 0)
    }

    func test__multiplication_int_1() {
        result = money * 1
        XCTAssertEqual(result, money)
    }

    func test__multiplication_int_2() {
        result = money * 417
        XCTAssertEqual(result, 4_165.83)
    }

    func test__multiplication_float_0() {
        result = money * 0.0
        XCTAssertEqual(result, 0)
    }

    func test__multiplication_float_1() {
        result = money * 1.0
        XCTAssertEqual(result, money)
    }

    func test__multiplication_float_2() {
        result = money * M_PI
        // Note - we use Banking style rounding mode
        XCTAssertEqual(result, 31.37)
    }
}

class MoneyDivisionTests: XCTestCase {
    var money: Cash!
    var result: Cash!

    override func setUp() {
        super.setUp()
        money = 9.99
    }

    override func tearDown() {
        money = nil
        result = nil
        super.tearDown()
    }

/*
    func test__division_int_0() {
        result = money / 0
        // This does throw an exception - but how can I 
        // write a test to verify that it does?
    }
*/

    func test__division_int_1() {
        result = money / 1
        XCTAssertEqual(result, money)
    }

    func test__multiplication_int_2() {
        result = money / 4
        XCTAssertEqual(result, 2.50)
    }

    func test__division_float_1() {
        result = money / 1.0
        XCTAssertEqual(result, money)
    }

    func test__division_float_2() {
        result = money / 4.0
        XCTAssertEqual(result, 2.50)
    }

    func test__division_float_3() {
        result = money / 0.5
        XCTAssertEqual(result, 19.98)
    }

    func test__division_float_4() {
        result = money / M_PI
        XCTAssertEqual(result, 3.18)
    }
}


