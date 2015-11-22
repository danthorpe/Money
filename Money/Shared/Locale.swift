//
//  Locale.swift
//  Money
//
//  Created by Daniel Thorpe on 22/11/2015.
//
//

import Foundation

public protocol LanguageType {
    var languageIdentifier: String { get }
}

public protocol CountryType {
    var countryIdentifier: String { get }
}

public protocol LocaleType {
    var localeIdentifier: String { get }
}

extension LocaleType where Self: LanguageType, Self: CountryType {
    public var localeIdentifier: String {
        guard !countryIdentifier.isEmpty else {
            return languageIdentifier
        }
        return "\(languageIdentifier)_\(countryIdentifier)"
    }
}