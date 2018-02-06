//
// Money
// File created on 20/09/2017.
// 	
// Copyright (c) 2015-2017 Daniel Thorpe
// 
// Money is licensed under the MIT License. Read the full license at 
// https://github.com/danthorpe/Money/blob/master/LICENSE
//

import Foundation

extension Decimal {

    func adding(_ other: Decimal) -> Decimal {
        var (lhs, rhs) = (self, other)
        var result = Decimal()
        NSDecimalAdd(&result, &lhs, &rhs, .bankers)
        return result
    }

    func subtracting(_ other: Decimal) -> Decimal {
        var (lhs, rhs) = (self, other)
        var result = Decimal()
        NSDecimalSubtract(&result, &lhs, &rhs, .bankers)
        return result
    }

    func multiplying(by other: Decimal) -> Decimal {
        var (lhs, rhs) = (self, other)
        var result = Decimal()
        NSDecimalMultiply(&result, &lhs, &rhs, .bankers)
        return result
    }

    func multiplying(byPowersOf10 index: Int16) -> Decimal {
        var lhs = self
        var result = Decimal()
        NSDecimalMultiplyByPowerOf10(&result, &lhs, index, .bankers)
        return result
    }

    func dividing(by other: Decimal) -> Decimal {
        var (lhs, rhs) = (self, other)
        var result = Decimal()
        NSDecimalDivide(&result, &lhs, &rhs, .bankers)
        return result

    }
}
