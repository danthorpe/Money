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

class NSDecimalTests: XCTestCase {

    var decimalNumberA: NSDecimalNumber!
    var decimalNumberB: NSDecimalNumber!
    var behaviors: NSDecimalNumberBehaviors!
    var a: NSDecimal!
    var b: NSDecimal!

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
        XCTAssertEqual(NSDecimal.zero(), NSDecimalNumber.zero().decimalValue)
    }

    func test__zero_is_not_equal_to_one() {
        XCTAssertNotEqual(NSDecimal.zero(), NSDecimal.one())
    }

    func test__zero_is_less_than_one() {
        XCTAssertTrue(NSDecimal.zero() < NSDecimal.one())
    }

    func test__zero_is_greater_than_negative_one() {
        XCTAssertTrue(NSDecimal.zero() > NSDecimal.one().negateWithRoundingMode(behaviors.roundingMode()))
    }

    func test__negative_one_is_negative() {
        XCTAssertTrue(NSDecimal.one().negateWithRoundingMode(behaviors.roundingMode()).isNegative)
    }

    func test__zero_is_not_negative() {
        XCTAssertFalse(NSDecimal.zero().isNegative)
        XCTAssertFalse(NSDecimal.one().isNegative)
    }

    func test__addition() {
        let result = a.add(b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.add(decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, 30)
    }

    func test__subtraction() {
        let result = a.subtract(b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.subtract(decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, -10)
    }

    func test__multiplication() {
        let result = a.multiplyBy(b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.multiplyBy(decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, 200)
    }

    func test__division() {
        let result = a.divideBy(b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.divideBy(decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, 0.5)
    }

    func test__remainder() {
        let result = a.remainder(b, withRoundingMode: behaviors.roundingMode())
        let _result = decimalNumberA.remainder(decimalNumberB, withBehaviors: behaviors)
        XCTAssertEqual(result, _result.decimalValue)
        XCTAssertEqual(_result, 10)
    }

}
