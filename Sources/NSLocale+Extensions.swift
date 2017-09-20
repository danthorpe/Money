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

/**
 Convenience currency related properties on NSLocale
 */
internal extension NSLocale {

    /// - returns: a String? for the currency code.
    var mny_currencyCode: String? {
        if #available(iOS 10.0, iOSApplicationExtension 10.0, watchOS 3.0, watchOSApplicationExtension 3.0, tvOS 10.0, tvOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *) {
            return currencyCode
        } else {
            return object(forKey: NSLocale.Key.currencyCode) as? String
        }
    }

    /// - returns: a String? for the currency symbol.
    var mny_currencySymbol: String? {
        if #available(iOS 10.0, iOSApplicationExtension 10.0, watchOS 3.0, watchOSApplicationExtension 3.0, tvOS 10.0, tvOSApplicationExtension 10.0, OSX 10.12, OSXApplicationExtension 10.12, *) {
            return currencySymbol
        } else {
            return object(forKey: NSLocale.Key.currencySymbol) as? String
        }
    }

    /// - returns: a String? for the currency grouping separator.
    var mny_currencyGroupingSeparator: String? {
        return object(forKey: NSLocale.Key.groupingSeparator) as? String
    }

    /// - returns: a String? for the currency decimal separator.
    var mny_currencyDecimalSeparator: String? {
        return object(forKey: NSLocale.Key.decimalSeparator) as? String
    }
}
