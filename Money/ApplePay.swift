//
//  ApplePay.swift
//  Money
//
//  Created by Daniel Thorpe on 16/11/2015.
//
//

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
