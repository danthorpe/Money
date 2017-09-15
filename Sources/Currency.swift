//
// Money
// File created on 15/09/2017.
// 	
// Copyright (c) 2015-2017 Daniel Thorpe
// 
// Money is licensed under the MIT License. Read the full license at 
// https://github.com/danthorpe/Money/blob/master/LICENSE
//

import Foundation

struct Currency: CurrencyProtocol {

    let code: String

    let scale: Int

    let symbol: String?

    init(code: String, scale: Int, symbol: String?) {
        self.code = code
        self.scale = scale
        self.symbol = symbol
    }
}

// MARK: - Conformance

extension Currency: Equatable {

    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code == rhs.code
            && lhs.scale == rhs.scale
            && lhs.symbol == rhs.symbol
    }
}

// MARK: - Convenience

extension Currency {

    static let device: Currency = {
        let locale = Locale.current
        var formatter = NumberFormatter()
        formatter.locale = locale
        let code = locale.currencyCode ?? "USD"
        let scale = formatter.maximumFractionDigits
        return Currency(code: code, scale: scale, symbol: locale.currencySymbol)
    }()
}
