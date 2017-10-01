//
// Money
// File created on 15/09/2017.
// 	
// Copyright (c) 2015-2017 Daniel Thorpe
// 
// Money is licensed under the MIT License. Read the full license at 
// https://github.com/danthorpe/Money/blob/master/LICENSE
//

import XCTest

@testable import Money

class MoneyTestCase: XCTestCase {

    var money: Money!
    var gbp: GBP!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        money = nil
        gbp = nil
        super.tearDown()
    }
}

extension Money {

    static func makeZero() -> Money {
        return Money()
    }
}
