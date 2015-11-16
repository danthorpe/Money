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
import ValueCoding

// MARK: - Apple Pay equivalent types

public enum PaymentSummaryItemType: Int {
    case Final = 1, Pending
}

public struct PaymentSummaryItem<Cost: MoneyType where Cost.DecimalStorageType == NSDecimalNumber, Cost.Coder: NSCoding, Cost.Coder.ValueType == Cost>: Hashable, ValueCoding {

    public typealias Coder = PaymentSummaryItemCoder<Cost>

    public let cost: Cost
    public let label: String
    public let type: PaymentSummaryItemType

    internal var amount: Cost.DecimalStorageType {
        return cost.amount
    }

    public var hashValue: Int {
        return cost.hashValue ^ (label.hashValue ^ type.hashValue)
    }

    public init(cost: Cost, label: String, type: PaymentSummaryItemType = .Final) {
        self.cost = cost
        self.label = label
        self.type = type
    }
}

extension PaymentSummaryItem {

    public func setCost(newCost: Cost) -> PaymentSummaryItem {
        return PaymentSummaryItem(cost: newCost, label: label, type: type)
    }

    public func setLabel(newLabel: String) -> PaymentSummaryItem {
        return PaymentSummaryItem(cost: cost, label: newLabel, type: type)
    }

    public func setType(newType: PaymentSummaryItemType) -> PaymentSummaryItem {
        return PaymentSummaryItem(cost: cost, label: label, type: newType)
    }
}

public func ==<Cost: MoneyType where Cost.DecimalStorageType == NSDecimalNumber>(lhs: PaymentSummaryItem<Cost>, rhs: PaymentSummaryItem<Cost>) -> Bool {
    return lhs.cost == rhs.cost && lhs.label == rhs.label && lhs.type == rhs.type
}

public final class PaymentSummaryItemCoder<Cost: MoneyType where Cost.DecimalStorageType == NSDecimalNumber, Cost.Coder: NSCoding, Cost.Coder.ValueType == Cost>: NSObject, NSCoding, CodingType {

    public let value: PaymentSummaryItem<Cost>

    public required init(_ v: PaymentSummaryItem<Cost>) {
        value = v
    }

    public init?(coder aDecoder: NSCoder) {
        let cost = Cost.decode(aDecoder.decodeObjectForKey("cost"))
        let label = aDecoder.decodeObjectForKey("label") as? String
        let type = PaymentSummaryItemType(rawValue: aDecoder.decodeIntegerForKey("type"))
        value = PaymentSummaryItem(cost: cost!, label: label!, type: type!)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.cost.encoded, forKey: "cost")
        aCoder.encodeObject(value.label, forKey: "label")
        aCoder.encodeInteger(value.type.rawValue, forKey: "type")
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

    convenience init<Cost: MoneyType where Cost.DecimalStorageType == NSDecimalNumber>(paymentSummaryItem: PaymentSummaryItem<Cost>) {
        self.init()
        amount = paymentSummaryItem.amount
        label = paymentSummaryItem.label
        if #available(iOSApplicationExtension 9.0, *) {
            type = PKPaymentSummaryItemType(paymentSummaryItemType: paymentSummaryItem.type)
        }
    }
}

public extension PKPaymentRequest {

    convenience init<Cost: MoneyType, Items: SequenceType where Cost.DecimalStorageType == NSDecimalNumber, Cost.Coder: NSCoding, Cost.Coder.ValueType == Cost, Items.Generator.Element == PaymentSummaryItem<Cost>>(items: Items) {
        self.init()
        currencyCode = Cost.Currency.code
        paymentSummaryItems = items.map { PKPaymentSummaryItem(paymentSummaryItem: $0) }
    }
}
