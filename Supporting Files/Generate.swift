#!/usr/bin/env xcrun -sdk macosx swift

//
//  Generate.swift
//  Money
//
//  Created by Daniel Thorpe on 01/11/2015.
//
//

import Foundation

typealias Writer = (String) -> Void
typealias Generator = (Writer) -> Void

func createExtensionFor(typename: String, writer: Writer, content: Generator) {
    writer("extension \(typename) {\n")
    content(writer)
    writer("\n}")
}

func createCurrencyCodeTypes(writer: Writer) {
    for code in NSLocale.ISOCurrencyCodes() {
        writer("\n")
        writer("    public final class \(code): BaseCurrency, CurrencyType {\n")
        writer("        public static var sharedInstance = \(code)(code: \"\(code)\")\n")
        writer("    }")
        writer("\n")
    }
}

func generate(outputPath: String) {

    guard let outputStream = NSOutputStream(toFileAtPath: outputPath, append: false) else {
        fatalError("Unable to create output stream at path: \(outputPath)")
    }
    let writer: Writer = { str in
        guard let data = str.dataUsingEncoding(NSUTF8StringEncoding) else {
            fatalError("Unable to encode string: \(str)")
        }
        outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }

    outputStream.open()
    createExtensionFor("Currency", writer: writer, content: createCurrencyCodeTypes)
    outputStream.close()
}

// MARK: - Main()

if Process.arguments.count == 1 {
    print("Invalid usage. Requires an output path.")
    exit(1)
}

let outputPath = Process.arguments[1]
print("Will output to path: \(outputPath)")
generate(outputPath)