//
//  Support.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

extension NSDecimalNumber {

    var isNegative: Bool {
        return NSDecimalNumber.zero().compare(self) == .OrderedDescending
    }

    static var negativeOne: NSDecimalNumber {
        return NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true)
    }
}

extension Int: BooleanType, BooleanLiteralConvertible {

    public var boolValue: Bool {
        switch self {
        case 0: return false
        default: return true
        }
    }

    public init(booleanLiteral value: BooleanLiteralType) {
        self = value ? 1 : 0
    }
}

