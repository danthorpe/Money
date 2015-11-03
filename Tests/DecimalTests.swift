//
//  DecimalTests.swift
//  Money
//
//  Created by Daniel Thorpe on 03/11/2015.
//
//

import XCTest
@testable import Money

class DecimalTests: XCTestCase {

    var decimal: Decimal!

    func test__decimal_decription1() {
        decimal = 10.00
        XCTAssertEqual(decimal.description, "10")
    }

    func test__decimal_decription2() {
        decimal = 10.01
        XCTAssertEqual(decimal.description, "10.01")
    }
}
