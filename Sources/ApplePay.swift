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
    case final = 1, pending
}

/**

 # PaymentSummaryItem

 A value type to represent a payment line item. It is generic over the
 `MoneyType` of the item cost. Other properties are a label and type.
 
 The money type must use `NSDecimalNumber` storage type, and correctly 
 conform to `ValueCoding`.
 */
public struct PaymentSummaryItem<Cost: MoneyType>: Hashable, ValueCoding where Cost.DecimalStorageType == NSDecimalNumber, Cost.Coder: NSCoding, Cost.Coder.Value == Cost {

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
    public init(label: String, cost: Cost, type: PaymentSummaryItemType = .final) {
        self.label = label
        self.type = type
        switch type {
        case .final:
            self.cost = cost
        case .pending:
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
    public func set(label newLabel: String) -> PaymentSummaryItem {
        return PaymentSummaryItem(label: newLabel, cost: cost, type: type)
    }

    /**
     Immutable setter for `cost` property
     - parameter newCost: the value for the `cost` property in an item copy
     - returns: a summary item with a new cost value, and previously set label and type.
    */
    public func set(cost newCost: Cost) -> PaymentSummaryItem {
        return PaymentSummaryItem(label: label, cost: newCost, type: type)
    }

    /**
     Immutable setter for `type` property
     - parameter newType: the value for the `type` property in an item copy
     - returns: a summary item with a new type value, and previously set label and cost.
     */
    public func set(type newType: PaymentSummaryItemType) -> PaymentSummaryItem {
        return PaymentSummaryItem(label: label, cost: cost, type: newType)
    }
}

/**
 Coding adaptor for `PaymentSummaryItem`.
*/
public final class PaymentSummaryItemCoder<Cost: MoneyType>: NSObject, NSCoding, CodingProtocol where Cost.DecimalStorageType == NSDecimalNumber, Cost.Coder: NSCoding, Cost.Coder.Value == Cost {

    public let value: PaymentSummaryItem<Cost>

    public required init(_ v: PaymentSummaryItem<Cost>) {
        value = v
    }

    public init?(coder aDecoder: NSCoder) {
        let cost = Cost.decode(aDecoder.decodeObject(forKey: "cost") as AnyObject?)
        let label = aDecoder.decodeObject(forKey: "label") as? String
        let type = PaymentSummaryItemType(rawValue: aDecoder.decodeInteger(forKey: "type"))
        value = PaymentSummaryItem(label: label!, cost: cost!, type: type!)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(value.label, forKey: "label")
        aCoder.encode(value.cost.encoded, forKey: "cost")
        aCoder.encode(value.type.rawValue, forKey: "type")
    }
}

// MARK: - Pay type extensions

@available(iOS 9.0, iOSApplicationExtension 9.0, *)
internal extension PKPaymentSummaryItemType {

    init(paymentSummaryItemType: PaymentSummaryItemType) {
        switch paymentSummaryItemType {
        case .final:
            self = .final
        case .pending:
            self = .pending
        }
    }
}

internal extension PKPaymentSummaryItem {

    convenience init<Cost: MoneyType>(paymentSummaryItem: PaymentSummaryItem<Cost>) where Cost.DecimalStorageType == NSDecimalNumber {
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
    convenience init<Cost: MoneyType>(items: [PaymentSummaryItem<Cost>], sellerName: String) where Cost.DecimalStorageType == NSDecimalNumber, Cost.Coder: NSCoding, Cost.Coder.Value == Cost {
        self.init()
        currencyCode = Cost.Currency.code
        var items = items
        let total = items.map { $0.cost }.reduce(0, +)
        items.append(PaymentSummaryItem(label: sellerName, cost: total))
        paymentSummaryItems = items.map { PKPaymentSummaryItem(paymentSummaryItem: $0) }
    }
}

// MARK: - Equality

public func ==<Cost: MoneyType>(lhs: PaymentSummaryItem<Cost>, rhs: PaymentSummaryItem<Cost>) -> Bool where Cost.DecimalStorageType == NSDecimalNumber {
    return lhs.cost == rhs.cost && lhs.label == rhs.label && lhs.type == rhs.type
}

#endif
