//
//  Money_iOSTests.swift
//  Money-iOSTests
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import XCTest
@testable import Money

class MoneyTests: XCTestCase {
    
    func test__money_value_is_set() {
        let money = Money()
        XCTAssertEqual(money.value, 10)
    }
}
