#!/usr/bin/env xcrun -sdk macosx swift

//
//  Generate.swift
//  Money
//
//  Created by Daniel Thorpe on 01/11/2015.
//
//

import Foundation

func createExtensionFor(typename: String, content: String) -> String {
    return "extension \(typename) {\n\(content)\n}"
}

func createCurrencyCodeTypes(codes: [String]) -> String {
    var output = ""
    for code in codes {
        output += "\n"
        output += "        public final class \(code): BaseCurrency, CurrencyType {\n"
        output += "            public static var sharedInstance = \(code)(code: \"\(code)\")\n"
        output += "        }"
    }
    return output
}

func generate(output: String) {
    let codes = NSLocale.ISOCurrencyCodes()
    let output = createExtensionFor("Currency", content: createCurrencyCodeTypes(codes))
    print("\(output)")
}

// MARK: - Main()

if Process.arguments.count == 1 {
    print("Invalid usage. Requires an output path.")
    exit(1)
}

let output = Process.arguments[1]
generate(output)