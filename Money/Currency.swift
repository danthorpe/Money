//
//  Currency.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

public protocol CurrencyType {
    static var formatter: NSNumberFormatter { get }
    static var scale: Int { get }
    static var decimalNumberBehavior: NSDecimalNumberBehaviors? { get }
}

extension CurrencyType {

    public static var scale: Int {
        return formatter.maximumFractionDigits
    }

    public static var decimalNumberBehavior: NSDecimalNumberBehaviors? {
        return NSDecimalNumberHandler(
            roundingMode: .RoundBankers,
            scale: Int16(scale),
            raiseOnExactness: true,
            raiseOnOverflow: true,
            raiseOnUnderflow: true,
            raiseOnDivideByZero: true
        )
    }

}



public struct LocalCurrency: CurrencyType {

    public static let formatter: NSNumberFormatter = {
        let fmtr = NSNumberFormatter()
        fmtr.numberStyle = .CurrencyStyle
        return fmtr
    }()
}
