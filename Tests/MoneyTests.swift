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
    var decNumber: NSDecimalNumber!

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

    func test__money_equals_decimal() {
        aMoney = 0
        decNumber = NSDecimalNumber.zero()
        XCTAssertTrue(aMoney == decNumber)
    }

    func test__money_does_not_equal_decimal() {
        aMoney = 0
        decNumber = NSDecimalNumber.one()
        XCTAssertFalse(decNumber == aMoney)
    }
}




