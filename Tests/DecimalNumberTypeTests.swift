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

class DecimalNumberTypeTests: XCTestCase {

    var decimal: PlainDecimal!
    var money: Money!

    func test__init_with_int() {
        let value: Int = 10
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_uint8() {
        let value: UInt8 = 10
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_int8() {
        let value: Int8 = 10
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_uint16() {
        let value: UInt16 = 10
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_int16() {
        let value: Int16 = 10
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_uint32() {
        let value: UInt32 = 10
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_int32() {
        let value: Int32 = 10
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_uint64() {
        let value: UInt64 = 10
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_int64() {
        let value: Int64 = 10
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_float() {
        let value: Float = 9.0
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 9.0)
        XCTAssertEqual(money, 9.00)
    }

    func test__init_with_double() {
        let value: Double = 9.999
        decimal = PlainDecimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 9.999)
        XCTAssertEqual(money, 10.00)
    }

    func testPerformanceInitInt() {
        measure {
            for value in 1...10_000 {
                self.money = Money(value)
            }
        }
    }

    func testPerformanceInitDouble() {
        let value: Double = 9.99
        measure {
            for _ in 1...10_000 {
                self.money = Money(value)
            }
        }
    }

}
