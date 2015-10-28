//
//  Money.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

protocol MoneyType {
    typealias Currency: CurrencyType
}

/**
 # Money
 
 Money is a value type, which is generic over the currency type.
 
 To work in whatever the local currency is, use `Cash`.

*/
public struct Money<C: CurrencyType>: Equatable, MoneyType {
    typealias Currency = C

    internal var value: NSDecimalNumber

    public init(_ value: NSDecimalNumber = NSDecimalNumber.zero()) {
        self.value = value
    }
}

public typealias Cash = Money<LocalCurrency>

// MARK: - Literal Convertibles

extension Money: FloatLiteralConvertible {

    public init(floatLiteral value: Double) {
        self.value = NSDecimalNumber(floatLiteral: value)
    }
}

extension Money: IntegerLiteralConvertible {

    public init(integerLiteral value: Int) {
        switch value {
        case 0:
            self.value = NSDecimalNumber.zero()
        case 1:
            self.value = NSDecimalNumber.one()
        default:
            self.value = NSDecimalNumber(integerLiteral: value)
        }
    }
}

// MARK: - Equality

public func ==<C: CurrencyType>(a: Money<C>, b: Money<C>) -> Bool {
    return a.value.isEqualToNumber(b.value)
}

public func ==<C: CurrencyType>(a: Money<C>, b: NSDecimalNumber) -> Bool {
    return a.value.isEqualToNumber(b)
}

public func ==<C: CurrencyType>(a: NSDecimalNumber, b: Money<C>) -> Bool {
    return a.isEqualToNumber(b.value)
}


