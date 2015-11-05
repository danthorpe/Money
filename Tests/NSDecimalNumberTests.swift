//
//  NSDecimalNumberTests.swift
//  Money
//
//  Created by Daniel Thorpe on 05/11/2015.
//
//

import XCTest
@testable import Money

class NSDecimalNumberTests: XCTestCase {

    var a: NSDecimalNumber!
    var b: NSDecimalNumber!
    var behaviors: NSDecimalNumberBehaviors!

    override func setUp() {
        super.setUp()
        a = 10
        b = 20
        behaviors = DecimalNumberBehavior.Plain.decimalNumberBehaviors
    }

    override func tearDown() {
        a = nil
        b = nil
        behaviors = nil
        super.tearDown()
    }

    func test__zero_is_not_equal_to_one() {
        XCTAssertNotEqual(NSDecimalNumber.zero(), NSDecimalNumber.one())
    }

    func test__zero_is_less_than_one() {
        XCTAssertTrue(NSDecimalNumber.zero() < NSDecimalNumber.one())
    }

    func test__zero_is_greater_than_negative_one() {
        XCTAssertTrue(NSDecimalNumber.zero() > NSDecimalNumber.one().negateWithBehaviors(behaviors))
    }

    func test__negative_one_is_negative() {
        XCTAssertTrue(NSDecimalNumber.one().negateWithBehaviors(behaviors).isNegative)
    }

    func test__zero_is_not_negative() {
        XCTAssertFalse(NSDecimalNumber.zero().isNegative)
        XCTAssertFalse(NSDecimalNumber.one().isNegative)
    }

    func test__addition() {
        let result = a.add(b, withBehaviors: behaviors)
        XCTAssertEqual(result, 30)
    }

    func test__subtraction() {
        let result = a.subtract(b, withBehaviors: behaviors)
        XCTAssertEqual(result, -10)
    }

    func test__multiplication() {
        let result = a.multiplyBy(b, withBehaviors: behaviors)
        XCTAssertEqual(result, 200)
    }

    func test__division() {
        let result = a.divideBy(b, withBehaviors: behaviors)
        XCTAssertEqual(result, 0.5)
    }

    func test__remainder() {
        let result = a.remainder(b, withBehaviors: behaviors)
        XCTAssertEqual(result, 10)
    }

    func test__remainder_swift_documentation_examples() {
        // https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/BasicOperators.html#//apple_ref/doc/uid/TP40014097-CH6-ID63

        a = 9; b = 4
        XCTAssertEqual(a.remainder(b, withBehaviors: behaviors), 1)

        a = -9; b = 4
        XCTAssertEqual(a.remainder(b, withBehaviors: behaviors), -1)

        a = 9; b = -4
        XCTAssertEqual(a.remainder(b, withBehaviors: behaviors), 1)

        a = 8; b = 2.5
        XCTAssertEqual(a.remainder(b, withBehaviors: behaviors), 0.5)
    }
}
