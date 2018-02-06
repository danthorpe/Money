#!/usr/bin/env xcrun -sdk macosx swift

//
//  Generate.swift
//  Money
//
//  Created by Daniel Thorpe on 01/11/2015.
//
//

import Foundation

enum Source {
    case source, tests
}

protocol WriterProtocol {

    func write(_ str: String)
}

typealias ContentWriter = (WriterProtocol) -> Void

class Writer: WriterProtocol {

    let stream: OutputStream

    init(destination: String) {
        guard let outputStream = OutputStream(toFileAtPath: destination, append: false) else {
            fatalError("Unable to create output stream at path: \(destination)")
        }
        stream = outputStream
        stream.open()
        createFrontMatter()
    }

    deinit {
        stream.close()
    }

    func write(_ str: String) {
        guard let data = str.data(using: String.Encoding.utf8) else {
            fatalError("Unable to encode str: \(str)")
        }
        let _ = data.withUnsafeBytes { stream.write($0, maxLength: data.count) }
    }
}

extension WriterProtocol {

    func line(_ str: String) {
        write("\(str)\n")
    }

    func createFrontMatter() {
        line("//")
        line("// Money")
        line("//")
        line("// Copyright (c) 2015-2017 Daniel Thorpe")
        line("//")
        line("// Money is licensed under the MIT License. Read the full license at")
        line("// https://github.com/danthorpe/Money/blob/master/LICENSE")
        line("//")
        line("// Autogenerated from build scripts, do not manually edit this file.")
        line("//")
        line("")
    }
}

// MARK: - Types

protocol TypeCreator {
    static var typeName: String { get }
    var displayName: String { get }
}

extension TypeCreator {

    var capitalizedName: String {
        return displayName.capitalized(with: Locale(identifier: "en_US"))
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "ʼ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "&", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "’", with: "")
    }

    var caseName: String {
        return capitalizedName
    }

    var caseNameValue: String {
        return ".\(caseName)"
    }

    var protocolName: String {
        return "\(capitalizedName)\(Self.typeName)Protocol"
    }
}

// MARK: - Writer Functions

func makeMoneyType(for code: String) -> String {
    return "ISOMoney<Currency.\(code)>"
}

func makeExtension(for typename: String, with writer: WriterProtocol, content: ContentWriter) {
    writer.line("extension \(typename) {")
    content(writer)
    writer.line("}")
}

// MARK: - Currencies & Monies

func makeCurrencyTypes(with writer: WriterProtocol) {
    for code in Locale.isoCurrencyCodes {
        writer.line("")
        writer.line("   /// Currency \(code)")
        writer.line("   public final class \(code): BaseCurrency, ISOCurrencyProtocol {")
        writer.line("      /// - returns: shared instance for Currency.\(code)")
        writer.line("      public static let shared = \(code)(code: \"\(code)\")")
        writer.line("   }")
    }
}

func makeMoneyTypes(with writer: WriterProtocol) {
    writer.line("")
    for code in Locale.isoCurrencyCodes {
        writer.line("")
        writer.line("/// \(code) Money")
        let name = makeMoneyType(for: code)
        writer.line("public typealias \(code) = \(name)")
    }
}






func generate(_ source: Source, to path: String) {

    let writer = Writer(destination: path)

    switch source {
    case .source:
        writer.line("// MARK: - Currencies")
        writer.line("")
        makeExtension(for: "Currency", with: writer, content: makeCurrencyTypes)
        writer.line("")
        writer.line("// MARK: - Money")
        writer.line("")
        makeMoneyTypes(with: writer)
    case .tests:
        break
    }
}

// MARK: - Main()
let process = Process()

let pathToSourceCodeFile = "\(process.currentDirectoryPath)/Sources/Autogenerated.swift"
generate(.source, to: pathToSourceCodeFile)

