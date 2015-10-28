//
//  Support.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

infix operator ** { associativity left precedence 160 }

func ** (left: Double, right: Double) -> Double {
    return pow(left, right)
}


extension NSDecimalNumber {

    static func minusOnewithBehavior(behavior: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return NSDecimalNumber.zero().decimalNumberBySubtracting(NSDecimalNumber.one(), withBehavior: behavior)
    }
}

