//
//  ApplePay.swift
//  Money
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

import Foundation
import PassKit

// MARK: - Apple Pay equivalent types

public enum PaymentSummaryItemType {
    case Final, Pending
}

public struct PaymentSummaryItem<M: MoneyType where M.DecimalStorageType == NSDecimalNumber> {
    public let money: M
    public let label: String
    public let type: PaymentSummaryItemType

    internal var amount: M.DecimalStorageType {
        return money.amount
    }

    public init(money: M, label: String, type: PaymentSummaryItemType = .Final) {
        self.money = money
        self.label = label
        self.type = type
    }
}

extension PaymentSummaryItem {

    public func setMoney(newMoney: M) -> PaymentSummaryItem {
        return PaymentSummaryItem(money: newMoney, label: label, type: type)
    }

    public func setLabel(newLabel: String) -> PaymentSummaryItem {
        return PaymentSummaryItem(money: money, label: newLabel, type: type)
    }

    public func setType(newType: PaymentSummaryItemType) -> PaymentSummaryItem {
        return PaymentSummaryItem(money: money, label: label, type: newType)
    }
}


// MARK: - Apple Pay type extensions

@available(iOSApplicationExtension 9.0, *)
extension PKPaymentSummaryItemType {

    init(paymentSummaryItemType: PaymentSummaryItemType) {
        switch paymentSummaryItemType {
        case .Final:
            self = .Final
        case .Pending:
            self = .Pending
        }
    }
}

extension PKPaymentSummaryItem {

    convenience init<M: MoneyType where M.DecimalStorageType == NSDecimalNumber>(paymentSummaryItem: PaymentSummaryItem<M>) {
        self.init()
        amount = paymentSummaryItem.amount
        label = paymentSummaryItem.label
        if #available(iOSApplicationExtension 9.0, *) {
            type = PKPaymentSummaryItemType(paymentSummaryItemType: paymentSummaryItem.type)
        }
    }
}

public extension PKPaymentRequest {

    convenience init<M: MoneyType, Items: SequenceType where M.DecimalStorageType == NSDecimalNumber, Items.Generator.Element == PaymentSummaryItem<M>>(items: Items) {
        self.init()
        currencyCode = M.Currency.code
        paymentSummaryItems = items.map { PKPaymentSummaryItem(paymentSummaryItem: $0) }
    }
}
