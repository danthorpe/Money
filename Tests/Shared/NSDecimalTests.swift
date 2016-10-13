//
//  NSDecimalTests.swift
//  Money
//
//  Created by Daniel Thorpe on 05/11/2015.
//
//

import XCTest
@testable import Money

class NSDecimalTests: XCTestCase {

    var decimalNumberA: NSDecimalNumber!
    var decimalNumberB: NSDecimalNumber!
    var behaviors: NSDecimalNumberBehaviors!
    var a: Decimal!
    var b: Decimal!

    override func setUp() {
        super.setUp()
        decimalNumberA = 10
        decimalNumberB = 20
        behaviors = DecimalNumberBehavior.Plain.decimalNumberBehaviors
        a = decimalNumberA.decimalValue
        b = decimalNumberB.decimalValue
    }

    override func tearDown() {
        decimalNumberA = nil
        decimalNumberB = nil
        behaviors = nil
        a = nil
        b = nil
        super.tearDown()
    }

    func test__zero() {
        XCTAssertEqual(Decimal.zero, NSDecimalNumber.zero.decimalValue)
    }

    func test__zero_is_not_equal_to_one() {
        XCTAssertNotEqual(Decimal.zero, Decimal.one)
    }

    func test__zero_is_less_than_one() {
        XCTAssertTrue(Decimal.zero < Decimal.one)
    }

    func test__zero_is_greater_than_negative_one() {
        XCTAssertTrue(Decimal.zero > Decimal.one.negate(withRoundingMode: behaviors.roundingMode()))
    }

    func test__negative_one_is_negative() {
        XCTAssertTrue(Decimal.one.negate(withRoundingMode: behaviors.roundingMode()).isNegative)
    }

    func test__zero_is_not_negative() {
        XCTAssertFalse(Decimal.zero.isNegative)
        XCTAssertFalse(Decimal.one.isNegative)
    }

    func test__addition() {
        let result = a.add(other: b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.add(decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, 30)
    }

    func test__subtraction() {
        let result = a.subtract(other: b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.subtract(decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, -10)
    }

    func test__multiplication() {
        let result = a.multiply(by: b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.multiply(by: decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, 200)
    }

    func test__division() {
        let result = a.divide(by: b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.divide(by: decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, 0.5)
    }

    func test__remainder() {
        let result = a.remainder(other: b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.remainder(other: decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, 10)
    }
}
