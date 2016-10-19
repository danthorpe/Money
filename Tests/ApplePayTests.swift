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

#if os(iOS)

import XCTest
import PassKit
@testable import Money

class ApplePayTests: XCTestCase {

    var item: PaymentSummaryItem<GBP>!
    var items: Set<PaymentSummaryItem<GBP>> = []

    override func setUp() {
        super.setUp()
        item = PaymentSummaryItem(label: "iPad Pro, 32GB with WiFi", cost: 679, type: .final)
        items.insert(item)
    }
}

class PaymentSummaryItemTests: ApplePayTests {

    func test__init__sets_money() {
        XCTAssertEqual(item.cost, 679)
    }

    func test__init__sets_label() {
        XCTAssertEqual(item.label, "iPad Pro, 32GB with WiFi")
    }

    func test__init__sets_type() {
        XCTAssertEqual(item.type, PaymentSummaryItemType.final)
    }

    func test__set_new_money__sets_money() {
        item = item.set(cost: 799)
        XCTAssertEqual(item.cost, 799)
        XCTAssertEqual(item.label, "iPad Pro, 32GB with WiFi")
        XCTAssertEqual(item.type, PaymentSummaryItemType.final)
    }

    func test__set_new_label__sets_label() {
        item = item.set(label: "iPad Pro, 128GB with WiFi")
        XCTAssertEqual(item.cost, 679)
        XCTAssertEqual(item.label, "iPad Pro, 128GB with WiFi")
        XCTAssertEqual(item.type, PaymentSummaryItemType.final)
    }

    func test__set_new_type__sets_type() {
        item = item.set(type: .pending)
        XCTAssertEqual(item.cost, 0)
        XCTAssertEqual(item.label, "iPad Pro, 32GB with WiFi")
        XCTAssertEqual(item.type, PaymentSummaryItemType.pending)
    }

    func test__equality() {
        XCTAssertEqual(item, PaymentSummaryItem<GBP>(label: "iPad Pro, 32GB with WiFi", cost: 679, type: .final))
        XCTAssertNotEqual(item, PaymentSummaryItem<GBP>(label: "iPad Pro, 128GB with WiFi", cost: 799, type: .final))
    }
}

class PaymentSummaryItemCodingTests: ApplePayTests {

    func archiveEncoded() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: item.encoded)
    }

    func unarchive(_ archive: Data) -> PaymentSummaryItem<GBP>? {
        return PaymentSummaryItem<GBP>.decode(NSKeyedUnarchiver.unarchiveObject(with: archive) as AnyObject?)
    }

    func test__encode_decode() {
        XCTAssertEqual(unarchive(archiveEncoded()), item)
    }
}

class PKPaymentSummaryItemTypeTests: ApplePayTests {

    func test__init__final() {
        let type = PKPaymentSummaryItemType(paymentSummaryItemType: .final)
        XCTAssertEqual(type, PKPaymentSummaryItemType.final)
    }

    func test__init__pending() {
        let type = PKPaymentSummaryItemType(paymentSummaryItemType: .pending)
        XCTAssertEqual(type, PKPaymentSummaryItemType.pending)
    }
}

class PKPaymentSummaryItemTests: ApplePayTests {

    func test__init__with_item() {
        let summaryItem = PKPaymentSummaryItem(paymentSummaryItem: item)
        XCTAssertEqual(summaryItem.amount, NSDecimalNumber(value: 679))
        XCTAssertEqual(summaryItem.label, "iPad Pro, 32GB with WiFi")
        XCTAssertEqual(summaryItem.type, PKPaymentSummaryItemType.final)
    }
}

class PKPaymentRequestTests: ApplePayTests {

    func test__init__with_items() {
        items.insert(PaymentSummaryItem(label: "iPad Pro, 128GB with WiFi", cost: 799, type: .final))
        items.insert(PaymentSummaryItem(label: "iPad Pro, 128GB with WiFi + Cellular", cost: 899, type: .final))
        let request = PKPaymentRequest(items: Array(items), sellerName: "Acme. Inc")

        XCTAssertEqual(request.currencyCode, GBP.Currency.code)
        XCTAssertEqual(request.paymentSummaryItems.count, 4)
        XCTAssertEqual(request.paymentSummaryItems.last!.label, "Acme. Inc")
        XCTAssertEqual(request.paymentSummaryItems.last!.amount, items.map { $0.cost }.reduce(0, +).amount)
    }
}

#endif

