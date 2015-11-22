//
//  DecimalNumberTypeTests.swift
//  Money
//
//  Created by Daniel Thorpe on 22/11/2015.
//
//

import XCTest
@testable import Money

class DecimalNumberTypeTests: XCTestCase {

    var decimal: Decimal!
    var money: Money!

    func test__init_with_int() {
        let value: Int = 10
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_uint8() {
        let value: UInt8 = 10
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_int8() {
        let value: Int8 = 10
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_uint16() {
        let value: UInt16 = 10
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_int16() {
        let value: Int16 = 10
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_uint32() {
        let value: UInt32 = 10
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_int32() {
        let value: Int32 = 10
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_uint64() {
        let value: UInt64 = 10
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_int64() {
        let value: Int64 = 10
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 10)
        XCTAssertEqual(money, 10)
    }

    func test__init_with_float() {
        let value: Float = 9.0
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 9.0)
        XCTAssertEqual(money, 9.00)
    }

    func test__init_with_double() {
        let value: Double = 9.999
        decimal = Decimal(value)
        money = Money(value)
        XCTAssertEqual(decimal, 9.999)
        XCTAssertEqual(money, 10.00)
    }

    func testPerformanceInitInt() {
        self.measureBlock {
            for value in 1...10_000 {
                self.money = Money(value)
            }
        }
    }

    func testPerformanceInitDouble() {
        let value: Double = 9.99
        self.measureBlock {
            for _ in 1...10_000 {
                self.money = Money(value)
            }
        }
    }

}
