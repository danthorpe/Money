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

    var money: Money!
    var gbp: GBP!
    var usd: USD!
    var cad: CAD!
    var aud: AUD!
    var eur: EUR!
    var jpy: JPY!
    var btc: BTC!

    override func tearDown() {
        super.tearDown()
        money = nil
        gbp = nil
        usd = nil
        cad = nil
        eur = nil
        jpy = nil
        btc = nil
    }
}

class MoneyInitializerTests: MoneyTests {

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

    func test__money_amount() {
        money = 10
        XCTAssertEqual(money.amount, NSDecimalNumber(integer: 10))
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
        XCTAssertEqual(dividend % divisor, -2.50)
    }

    func test__remainer_negative_divisor() {
        dividend = 37.50
        divisor = -5
        XCTAssertEqual(dividend % divisor, 2.50)
    }

    func test__remainer_negative_dividend() {
        dividend = -37.50
        divisor = 5
        XCTAssertEqual(dividend % divisor, -2.50)
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

class MoneyConversionTests: XCTestCase {
    let input: GBP = 100

    func test__convert_with_rate_to_other() {
        let output: EUR = input.convertWithRate(1.2)
        XCTAssertEqual(output, 120)
    }
}

class MoneyDescriptionTests: MoneyTests {

    override func setUp() {
        super.setUp()
        money = 3.99
        gbp = 100
        usd = 99
        cad = 102.01
        aud = 99.999
        eur = 249.499
        jpy = 32_000
        btc = 0.002_007
    }

    func test__money_description() {
        XCTAssertEqual(money.description.endIndex, money.description.rangeOfString("3.99")?.endIndex)
    }

    func test__gbp_description() {
        XCTAssertEqual(gbp.currencyCode, "GBP")
        XCTAssertEqual(gbp.currencySymbol, "£")
        XCTAssertEqual(gbp.description, "£100.00")
    }

    func test__usd_formatted_with_style() {
        XCTAssertEqual(usd.currencyCode, "USD")
        let formatted = usd.formattedWithStyle(.CurrencyStyle, forLocale: .English(.UnitedStates))
        XCTAssertEqual(formatted, "US$99.00")
    }

    func test__btc_formatted_with_style() {
        XCTAssertEqual(btc.currencyCode, "BTC")
        let formatted = btc.formattedWithStyle(.CurrencyStyle, forLocale: .English(.UnitedStates))
        XCTAssertEqual(formatted, "Ƀ0.002007")
    }

    func test__btc_formatted_with_style_for_locale() {
        XCTAssertEqual(btc.currencyCode, "BTC")
        let formatted = btc.formattedWithStyle(.CurrencyStyle, forLocale: .Spanish(.Mexico))
        XCTAssertEqual(formatted, "Ƀ0.002007")
    }

    func test__cad_description() {
        XCTAssertEqual(cad.currencyCode, "CAD")
        XCTAssertEqual(cad.description, "CA$102.01")
    }

    func test__aud_description() {
        XCTAssertEqual(aud.currencyCode, "AUD")
        XCTAssertEqual(aud.description, "A$100.00")
    }

    func test__eur_description() {
        XCTAssertEqual(eur.currencyCode, "EUR")
        XCTAssertEqual(eur.description, "€249.50")
    }

    func test__jpy_description() {
        XCTAssertEqual(jpy.currencyCode, "JPY")
        XCTAssertEqual(JPY.Currency.scale, 0)
        if NSLocale.currentLocale().localeIdentifier == "en_US" {

        }
        else {
            XCTAssertEqual(jpy.description, "JP¥32,000")
        }
    }

    func test__jpy_formatted_with_style_for_locale() {
        let formatted = jpy.formattedWithStyle(.CurrencyStyle, forLocale: .German(.Germany))
        XCTAssertEqual(formatted, "32.000 JP¥")
    }
}

class MoneyFormattingTests: MoneyTests {

    override func setUp() {
        super.setUp()
        gbp = 100
        usd = 99
        cad = 102.01
        aud = 99.999
        eur = 249.499
        jpy = 32_000
    }

    // Tests assume a en_GB test environment
    func test__locale_identifier_equals_current_locale() {
        let gb = NSLocale.currentLocale().localeIdentifier == Locale.English(.UnitedKingdom).localeIdentifier
        let us = NSLocale.currentLocale().localeIdentifier == Locale.English(.UnitedStates).localeIdentifier
        XCTAssertTrue(gb || us)
    }

    func test__formatted_for_Spanish_Spain() {
        let result = gbp.formattedWithStyle(.CurrencyStyle, forLocale: .Spanish(.Spain))
        XCTAssertEqual(result, "100,00 £")
    }

    func test__formatted_for_English_UnitedKingdom() {
        let result = gbp.formattedWithStyle(.CurrencyStyle, forLocale: .English(.UnitedKingdom))
        XCTAssertEqual(result, "£100.00")
    }
}

class MoneyValueCodingTests: XCTestCase {

    var money: Money!

    func archiveEncodedMoney() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(money.encoded)
    }

    func unarchive(archive: NSData) -> Money? {
        return Money.decode(NSKeyedUnarchiver.unarchiveObjectWithData(archive))
    }

    func test__money_encodes() {
        money = 10
        XCTAssertEqual(unarchive(archiveEncodedMoney()), money)
    }
}

class MoneyMinorUnitTests: XCTestCase {
    
    func test__money_with_USD_minor_amount_equality() {
        XCTAssertEqual(USD(minorUnits: 3250), 32.50)
    }
    
    func test__money_with_JPY_minor_amount_equality() {
        XCTAssertEqual(JPY(minorUnits: 2170), 2170)
    }

    func test__money_with_BTC_minor_amount_equality() {
        XCTAssertEqual(BTC(minorUnits: 3000), 0.00003)
    }

    func test__money_access_minor_units() {
        XCTAssertEqual(JPY(integerLiteral: 1).minorUnits, 1)        
        XCTAssertEqual(USD(integerLiteral: 1).minorUnits, 100)
        XCTAssertEqual(BTC(integerLiteral: 1).minorUnits, 1_0000_0000)
    }
}

class CustomCurrencyWithoutSymbol: CustomCurrencyType {
    static let code: String = "DAN"
    static let scale: Int = 3
    static let symbol: String? = .None
}

class CurrencyTests: XCTestCase {

    func test__formatted_with_style() {
        let formating = Currency.GBP.formattedWithStyle(.CurrencyISOCodeStyle, forLocale: NSLocale.currentLocale())
        let result = formating(NSDecimalNumber(double: 10))
        XCTAssertEqual(result, "GBP10.00")
    }

    func test__formatted_with_iso_style__with_no_symbol() {
        let formating = CustomCurrencyWithoutSymbol.formattedWithStyle(.CurrencyISOCodeStyle, forLocale: NSLocale.currentLocale())
        let result = formating(NSDecimalNumber(double: 10.1234))
        XCTAssertEqual(result, "DAN10.123")
    }

    func test__formatted_with_default_style__with_no_symbol() {
        let formating = CustomCurrencyWithoutSymbol.formattedWithStyle(.CurrencyStyle, forLocale: NSLocale.currentLocale())
        let result = formating(NSDecimalNumber(double: 10.1234))
        XCTAssertEqual(result, "DAN10.123")
    }
}


