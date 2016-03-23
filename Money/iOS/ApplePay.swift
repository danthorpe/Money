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

// MARK: - Pay equivalent types

/**

 # PaymentSummaryItemType

 An equivalent `PKPaymentSummaryItemType` enum. While defined
 for iOS 8, usage will only have an impact on iOS 9.

 - see: PKPaymentSummaryItemType
 */
public enum PaymentSummaryItemType: Int {
    case Final = 1, Pending
}

/**

 # PaymentSummaryItem

 A value type to represent a payment line item. It is generic over the
 `MoneyType` of the item cost. Other properties are a label and type.
 
 The money type must use `NSDecimalNumber` storage type, and correctly 
 conform to `ValueCoding`.
 */
public struct PaymentSummaryItem<Cost: MoneyType where Cost.DecimalStorageType == NSDecimalNumber, Cost.Coder: NSCoding, Cost.Coder.ValueType == Cost>: Hashable, ValueCoding {

    /// The ValueCoding Coder type
    public typealias Coder = PaymentSummaryItemCoder<Cost>

    /**
     A label for the item.
     - returns: a `String` value
     */
    public let label: String

    /**
     The cost of the item.
     - returns: a `Cost` value
    */
    public let cost: Cost

    /**
     The cost type of the item. See docs for 
     `PKPaymentSummaryItemType`.
     - returns: a `PaymentSummaryItemType` value
     */
    public let type: PaymentSummaryItemType

    internal var amount: Cost.DecimalStorageType {
        return cost.amount
    }

    public var hashValue: Int {
        return cost.hashValue ^ (label.hashValue ^ type.hashValue)
    }

    /**
     Create a new `PaymentSummaryItem` with a cost, label and type.
     
     - discussion: As per the documentation of `PKPaymentSummaryItem` use 
     a `.Pending` item type, for when the final value is not known
     yet, e.g. a taxi fare. In which case, the cost should be zero. On iOS
     9 we will automaticaly set the cost to zero for pending type.

     - parameter label: the value for the `label` property.
     - parameter cost: the value for the `cost` property.
     - parameter type: the value for the `type` property.     
     - returns: a summary item with a given label, cost and type.
    */
    public init(label: String, cost: Cost, type: PaymentSummaryItemType = .Final) {
        self.label = label
        self.type = type
        switch type {
        case .Final:
            self.cost = cost
        case .Pending:
            self.cost = 0
        }
    }
}

extension PaymentSummaryItem {

    /**
     Immutable setter for `label` property
     - parameter newLabel: the value for the `label` property in an item copy
     - returns: a summary item with a new label value, and previously set cost and type.
     */
    public func setLabel(newLabel: String) -> PaymentSummaryItem {
        return PaymentSummaryItem(label: newLabel, cost: cost, type: type)
    }

    /**
     Immutable setter for `cost` property
     - parameter newCost: the value for the `cost` property in an item copy
     - returns: a summary item with a new cost value, and previously set label and type.
    */
    public func setCost(newCost: Cost) -> PaymentSummaryItem {
        return PaymentSummaryItem(label: label, cost: newCost, type: type)
    }

    /**
     Immutable setter for `type` property
     - parameter newType: the value for the `type` property in an item copy
     - returns: a summary item with a new type value, and previously set label and cost.
     */
    public func setType(newType: PaymentSummaryItemType) -> PaymentSummaryItem {
        return PaymentSummaryItem(label: label, cost: cost, type: newType)
    }
}

/**
 Coding adaptor for `PaymentSummaryItem`.
*/
public final class PaymentSummaryItemCoder<Cost: MoneyType where Cost.DecimalStorageType == NSDecimalNumber, Cost.Coder: NSCoding, Cost.Coder.ValueType == Cost>: NSObject, NSCoding, CodingType {

    public let value: PaymentSummaryItem<Cost>

    public required init(_ v: PaymentSummaryItem<Cost>) {
        value = v
    }

    public init?(coder aDecoder: NSCoder) {
        let cost = Cost.decode(aDecoder.decodeObjectForKey("cost"))
        let label = aDecoder.decodeObjectForKey("label") as? String
        let type = PaymentSummaryItemType(rawValue: aDecoder.decodeIntegerForKey("type"))
        value = PaymentSummaryItem(label: label!, cost: cost!, type: type!)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.label, forKey: "label")
        aCoder.encodeObject(value.cost.encoded, forKey: "cost")
        aCoder.encodeInteger(value.type.rawValue, forKey: "type")
    }
}

// MARK: - Pay type extensions

@available(iOS 9.0, iOSApplicationExtension 9.0, *)
internal extension PKPaymentSummaryItemType {

    init(paymentSummaryItemType: PaymentSummaryItemType) {
        switch paymentSummaryItemType {
        case .Final:
            self = .Final
        case .Pending:
            self = .Pending
        }
    }
}

internal extension PKPaymentSummaryItem {

    convenience init<Cost: MoneyType where Cost.DecimalStorageType == NSDecimalNumber>(paymentSummaryItem: PaymentSummaryItem<Cost>) {
        self.init()
        amount = paymentSummaryItem.amount
        label = paymentSummaryItem.label
        if #available(iOS 9.0, iOSApplicationExtension 9.0, *) {
            type = PKPaymentSummaryItemType(paymentSummaryItemType: paymentSummaryItem.type)
        }
    }
}

public extension PKPaymentRequest {

    /**
     Create a payment request with a sequence of `PaymentSummaryItem`s. The
     currency code will automatically be set. 
     
     As per the guidlines the total cost is calculated and appended to the
     end of the list, using your company or seller name as the label.
     
     - see: [guideline](https://developer.apple.com/library/ios/ApplePay_Guide/CreateRequest.html)

     - parameter items: an array of `PaymentSummaryItem<Cost>` values.
     - parameter sellerName: a `String` which is used in the total cost summary item.
     - returns: a `PKPaymentRequest` which has its payment summary items and currency code set.
    */
    convenience init<Cost: MoneyType where Cost.DecimalStorageType == NSDecimalNumber, Cost.Coder: NSCoding, Cost.Coder.ValueType == Cost>(items: [PaymentSummaryItem<Cost>], sellerName: String) {
        self.init()
        currencyCode = Cost.Currency.code
        var items = items
        let total = items.map { $0.cost }.reduce(0, combine: +)
        items.append(PaymentSummaryItem(label: sellerName, cost: total))
        paymentSummaryItems = items.map { PKPaymentSummaryItem(paymentSummaryItem: $0) }
    }
}

// MARK: - Equality

public func ==<Cost: MoneyType where Cost.DecimalStorageType == NSDecimalNumber>(lhs: PaymentSummaryItem<Cost>, rhs: PaymentSummaryItem<Cost>) -> Bool {
    return lhs.cost == rhs.cost && lhs.label == rhs.label && lhs.type == rhs.type
}

