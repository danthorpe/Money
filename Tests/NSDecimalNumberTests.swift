//
// Money, https://github.com/danthorpe/Money
// Created by Dan Thorpe, @danthorpe
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Daniel Thorpe
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
        XCTAssertNotEqual(NSDecimalNumber.zero, NSDecimalNumber.one)
    }

    func test__zero_is_less_than_one() {
        XCTAssertTrue(NSDecimalNumber.zero < NSDecimalNumber.one)
    }

    func test__zero_is_greater_than_negative_one() {
        XCTAssertTrue(NSDecimalNumber.zero > NSDecimalNumber.one.negate(withBehavior: behaviors))
    }

    func test__negative_one_is_negative() {
        XCTAssertTrue(NSDecimalNumber.one.negate(withBehavior: behaviors).isNegative)
    }

    func test__zero_is_not_negative() {
        XCTAssertFalse(NSDecimalNumber.zero.isNegative)
        XCTAssertFalse(NSDecimalNumber.one.isNegative)
    }

    func test__addition() {
        let result = a.adding(b, withBehavior: behaviors)
        XCTAssertEqual(result, 30)
    }

    func test__subtraction() {
        let result = a.subtracting(b, withBehavior: behaviors)
        XCTAssertEqual(result, -10)
    }

    func test__multiplication() {
        let result = a.multiplying(by: b, withBehavior: behaviors)
        XCTAssertEqual(result, 200)
    }

    func test__division() {
        let result = a.dividing(by: b, withBehavior: behaviors)
        XCTAssertEqual(result, 0.5)
    }

    func test__remainder() {
        let result = a.remainder(b, withBehavior: behaviors)
        XCTAssertEqual(result, 10)
    }

    func test__remainder_swift_documentation_examples() {
        // https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/BasicOperators.html#//apple_ref/doc/uid/TP40014097-CH6-ID63

        a = 9; b = 4
        XCTAssertEqual(a.remainder(b, withBehavior: behaviors), 1)

        a = -9; b = 4
        XCTAssertEqual(a.remainder(b, withBehavior: behaviors), -1)

        a = 9; b = -4
        XCTAssertEqual(a.remainder(b, withBehavior: behaviors), 1)

        a = 8; b = 2.5
        XCTAssertEqual(a.remainder(b, withBehavior: behaviors), 0.5)
    }
}
