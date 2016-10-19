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
import ValueCoding
@testable import Money

class PlainDecimalTestCase: XCTestCase {
    var decimal: PlainDecimal!

    override func tearDown() {
        decimal = nil
        super.tearDown()
    }
}

class DecimalAccessorTests: PlainDecimalTestCase {

    func test__decimal_integer_value() {
        decimal = 10.00
        XCTAssertEqual(decimal.integerValue, 10)
    }

    func test__decimal_float_value() {
        decimal = 10.00
        XCTAssertEqual(decimal.floatValue, 10.0)
    }
}

class DecimalDescriptionTests: PlainDecimalTestCase {

    func test__decimal_decription1() {
        decimal = 10.00
        XCTAssertEqual(decimal.description, "10")
    }

    func test__decimal_decription2() {
        decimal = 10.01
        XCTAssertEqual(decimal.description, "10.01")
    }
}

class DecimalReciprocalTests: PlainDecimalTestCase {

    func test__reciprocal() {
        decimal = 10
        XCTAssertEqual(decimal.reciprocal, 0.1)
    }

    func test__reciprocal_unity() {
        decimal = 1
        XCTAssertEqual(decimal.reciprocal, 1)
    }
}

class DecimalNumberConversionTests: PlainDecimalTestCase {
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

class DecimalValueCodingTests: PlainDecimalTestCase {

    func archiveEncodedDecimal() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: decimal.encoded)
    }

    func unarchive(_ archive: Data) -> PlainDecimal? {
        return PlainDecimal.decode(NSKeyedUnarchiver.unarchiveObject(with: archive) as AnyObject?)
    }

    func test__decimal_encodes() {
        decimal = 10
        XCTAssertEqual(unarchive(archiveEncodedDecimal()), decimal)
    }
}


