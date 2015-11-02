//
//  Money_iOSTests.swift
//  Money-iOSTests
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import XCTest
@testable import Money

class MoneyInitializerTests: XCTestCase {

    var money: Money!

    func test__money_initialize_with__nothing() {
        money = Money()
        XCTAssertEqual(money, 0)
    }

    func test__money_initialize_with__one_int() {
        money = Money(integerLiteral: 1)
        XCTAssertEqual(money, 1)
    }
    
    func test__money_is_negative() {
        money = -10
        XCTAssertTrue(money.isNegative)
    }
    
    func test__money_can_be_negated() {
        money = 10
        XCTAssertEqual(money.negative, -10)
    }
}

class MoneyEqualityTests: XCTestCase {
    var aMoney: USD!
    var bMoney: USD!

    func test__money_equals_money() {
        aMoney = 6.66
        bMoney = 6.66
        XCTAssertEqual(aMoney, bMoney)
    }

    func test__money_does_not_equal_money() {
        aMoney = 6.66
        bMoney = 5.66
        XCTAssertNotEqual(aMoney, bMoney)
    }
}

class MoneyComparableTests: XCTestCase {

    func test__money_sorts() {
        let monies: [Money] = [ 0, 12, 4.50, 9.99, 99, 9.99, 2.49, 16.69]
        let sorted = monies.sort()
        XCTAssertEqual(sorted, [0, 2.49, 4.50, 9.99, 9.99, 12, 16.69, 99])
    }
}

class MoneySignedNumberTests: XCTestCase {

    func test__money_negates() {
        let money: Money = 16.49
        let modified = -money
        XCTAssertEqual(modified, Money(floatLiteral: -16.49))
    }

    func test__money_subtracts() {
        let a: Money = 16.49
        let b: Money = 6.49
        let result = a - b
        XCTAssertEqual(result, Money(integerLiteral: 10))
    }
}

class MoneySubtractionTests: XCTestCase {

    let money: JPY = 12_345.67

    func test__subtraction_int_1() {
        XCTAssertEqual(money - 10_000, 2_345.67)
    }

    func test__subtraction_int_2() {
        XCTAssertEqual(10_000 - money, -2_345.67)
    }

    func test__subtraction_float_1() {
        XCTAssertEqual(money - 2_345.67, 10_000)
    }

    func test__subtraction_float_2() {
        XCTAssertEqual(2_345.67 - money, -10_000)
    }
}

class MoneyAddingTests: XCTestCase {

    let money: INR = 335_577.99

    func test_addition() {
        let cash: INR = 446_688.00
        XCTAssertEqual(money + cash, 782_265.99)
        XCTAssertEqual(cash + money, 782_265.99)
    }

    func test__addition_int_interal() {
        XCTAssertEqual(money + 10_000, 345_577.99)
        XCTAssertEqual(10_000 + money, 345_577.99)
    }

    func test__addition_float_interal() {
        XCTAssertEqual(money + 2_345.67, 337_923.66)
        XCTAssertEqual(2_345.67 + money, 337_923.66)
    }
}

class MoneyRemainderTests: XCTestCase {
    var dividend: EUR!
    var divisor: EUR!

    func test__remainer_all_positive() {
        dividend = 37.50
        divisor = 5
        XCTAssertEqual(dividend % divisor, 2.50)
    }

    func test__remainer_all_negative() {
        dividend = -37.50
        divisor = -5
        XCTAssertEqual(dividend % divisor, 2.50)
    }

    func test__remainer_negative_divisor() {
        dividend = 37.50
        divisor = -5
        XCTAssertEqual(dividend % divisor, 2.50)
    }

    func test__remainer_negative_dividend() {
        dividend = -37.50
        divisor = 5
        XCTAssertEqual(dividend % divisor, 2.50)
    }
}

class MoneyMultiplicationTests: XCTestCase {
    let money: CNY = 9.99

    func test__multiplication_int_0() {
        XCTAssertEqual(0 * money, 0)
    }

    func test__multiplication_int_1() {
        XCTAssertEqual(money * 1, money)
    }

    func test__multiplication_int_2() {
        XCTAssertEqual(money * 417, 4_165.83)
    }

    func test__multiplication_float_0() {
        XCTAssertEqual(0.0 * money, 0)
    }

    func test__multiplication_float_1() {
        XCTAssertEqual(money * 1.0, money)
    }

    func test__multiplication_float_2() {
        XCTAssertEqual(money * M_PI, 31.37)
    }
}

class MoneyDivisionTests: XCTestCase {
    let money: EUR = 9.99

/*
    func test__division_int_0() {
        result = money / 0
        // This does throw an exception - but how can I 
        // write a test to verify that it does?
    }
*/

    func test__division_int_1() {
        XCTAssertEqual(money / 1, money)
    }

    func test__multiplication_int_2() {
        XCTAssertEqual(money / 4, 2.50)
    }

    func test__division_float_1() {
        XCTAssertEqual(money / 1.0, money)
    }

    func test__division_float_2() {
        XCTAssertEqual(money / 4.0, 2.50)
    }

    func test__division_float_3() {
        XCTAssertEqual(money / 0.5, 19.98)
    }

    func test__division_float_4() {
        XCTAssertEqual(money / M_PI, 3.18)
    }
}

class MoneyDescriptionTests: XCTestCase {

    let gbp: GBP = 100
    let usd: USD = 99
    let cad: CAD = 102.01
    let aud: AUD = 99.999
    let eur: EUR = 249.499
    let jpy: JPY = 319.500002

    func test__gbp_description() {
        XCTAssertEqual(gbp.description, "£ 100.00")
    }

    func test__usd_description() {
        XCTAssertEqual(usd.description, "US$ 99.00")
    }

    func test__cad_description() {
        XCTAssertEqual(cad.description, "CA$ 102.01")
    }

    func test__aud_description() {
        XCTAssertEqual(aud.description, "A$ 100.00")
    }

    func test__eur_description() {
        XCTAssertEqual(eur.description, "€ 249.50")
    }

    func test__jpy_description() {
        XCTAssertEqual(jpy.description, "JP¥ 320")
    }
}
