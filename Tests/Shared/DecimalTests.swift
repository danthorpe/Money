//
//  DecimalTests.swift
//  Money
//
//  Created by Daniel Thorpe on 03/11/2015.
//
//

import XCTest
import ValueCoding
@testable import Money

class DecimalTests: XCTestCase {
    var decimal: Decimal!

    override func tearDown() {
        decimal = nil
        super.tearDown()
    }
}

class DecimalAccessorTests: DecimalTests {

    func test__decimal_integer_value() {
        decimal = 10.00
        XCTAssertEqual(decimal.integerValue, 10)
    }

    func test__decimal_float_value() {
        decimal = 10.00
        XCTAssertEqual(decimal.floatValue, 10.0)
    }
}

class DecimalDescriptionTests: DecimalTests {

    func test__decimal_decription1() {
        decimal = 10.00
        XCTAssertEqual(decimal.description, "10")
    }

    func test__decimal_decription2() {
        decimal = 10.01
        XCTAssertEqual(decimal.description, "10.01")
    }
}

class DecimalReciprocalTests: DecimalTests {

    func test__reciprocal() {
        decimal = 10
        XCTAssertEqual(decimal.reciprocal, 0.1)
    }

    func test__reciprocal_unity() {
        decimal = 1
        XCTAssertEqual(decimal.reciprocal, 1)
    }
}

class DecimalNumberConversionTests: DecimalTests {
    var money: GBP!

    override func setUp() {
        super.setUp()
        decimal = 10
        money = 20
    }

    override func tearDown() {
        money = nil
        super.tearDown()
    }

    func test__multiply() {
        let result = decimal * money
        XCTAssertEqual(result.description, "£200.00")
        XCTAssertEqual(money * decimal, 200)
    }

    func test__divide() {
        let result = decimal / money
        XCTAssertEqual(result.description, "£0.50")
        XCTAssertEqual(money / decimal, 2)
    }
}

class DecimalValueCodingTests: DecimalTests {

    func archiveEncodedDecimal() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(decimal.encoded)
    }

    func unarchive(archive: NSData) -> Decimal? {
        return Decimal.decode(NSKeyedUnarchiver.unarchiveObjectWithData(archive))
    }

    func test__decimal_encodes() {
        decimal = 10
        XCTAssertEqual(unarchive(archiveEncodedDecimal()), decimal)
    }
}


