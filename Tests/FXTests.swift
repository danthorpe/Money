//
//  FXTests.swift
//  Money
//
//  Created by Daniel Thorpe on 02/11/2015.
//
//

import XCTest
import Result
import SwiftyJSON
import DVR
@testable import Money

class Sessions {

    static func sessionWithCassetteName(name: String) -> Session {
        return sharedInstance.sessionWithCassetteName(name)
    }

    static let sharedInstance = Sessions()

    var sessions = Dictionary<String, Session>()

    func sessionWithCassetteName(name: String) -> Session {
        guard let session = sessions[name] else {
            let _session = Session(cassetteName: name)
            sessions.updateValue(_session, forKey: name)
            return _session
        }
        return session
    }
}

class TestableFXRemoteProvider<Provider: FXRemoteProviderType>: FXRemoteProviderType {

    typealias CounterMoney = Provider.CounterMoney
    typealias BaseMoney = Provider.BaseMoney

    static func name() -> String {
        return Provider.name()
    }

    static func session() -> NSURLSession {
        return Sessions.sessionWithCassetteName(name())
    }

    static func request() -> NSURLRequest {
        return Provider.request()
    }

    static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<FXQuote, FXError> {
        return Provider.quoteFromNetworkResult(result)
    }
}

class FaultyFXRemoteProvider<Provider: FXRemoteProviderType>: FXRemoteProviderType {

    typealias CounterMoney = Provider.CounterMoney
    typealias BaseMoney = Provider.BaseMoney

    static func name() -> String {
        return Provider.name()
    }

    static func session() -> NSURLSession {
        return Provider.session()
    }

    static func request() -> NSURLRequest {
        let request = Provider.request()
        if let url = request.URL,
            host = url.host,
            modified = NSURL(string: url.absoluteString.stringByReplacingOccurrencesOfString(host, withString: "broken-host.xyz")) {
                return NSURLRequest(URL: modified)
        }
        return request
    }

    static func quoteFromNetworkResult(result: Result<(NSData?, NSURLResponse?), NSError>) -> Result<FXQuote, FXError> {
        return Provider.quoteFromNetworkResult(result)
    }
}


class FakeLocalFX<B: MoneyType, C: MoneyType where
    B.Coder: NSCoding,
    B.Coder.ValueType == B,
    B.DecimalStorageType == BankersDecimal.DecimalStorageType,
    C.Coder: NSCoding,
    C.Coder.ValueType == C,
    C.DecimalStorageType == BankersDecimal.DecimalStorageType>: FXLocalProviderType {

    typealias BaseMoney = B
    typealias CounterMoney = C

    static func name() -> String {
        return "LocalFX"
    }

    static func quote() -> FXQuote {
        return FXQuote(rate: 1.1)
    }
}


class FXErrorTests: XCTestCase {

    func test__fx_error__equality() {
        XCTAssertNotEqual(FXError.NoData, FXError.RateNotFound("whatever"))
    }
}

class FXProviderTests: XCTestCase {

    func dvrJSONFromCassette(name: String) -> JSON? {
        guard let path = NSBundle(forClass: self.dynamicType).pathForResource(name, ofType: "json"),
            data = NSData(contentsOfFile: path) else {
                return .None
        }
        let json = JSON(data: data)
        let body = json[["interactions",0,"response","body"]]
        return body
    }
}

class FXLocalProviderTests: XCTestCase {

    func test_fx() {
        XCTAssertEqual(FakeLocalFX<Money, USD>.fx(100).counter, 110)
    }
}

class FXQuoteTests: XCTestCase {

    var quote: FXQuote!

    func archiveEncodedQuote() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(quote.encoded)
    }

    func unarchive(archive: NSData) -> FXQuote? {
        return FXQuote.decode(NSKeyedUnarchiver.unarchiveObjectWithData(archive))
    }

    func test__quote_encodes() {
        quote = FXQuote(rate: 1.5409)
        XCTAssertEqual(unarchive(archiveEncodedQuote())!.rate, quote.rate)
    }
}

class FXTransactionTests: XCTestCase {

    typealias Transaction = FXTransaction<USD, GBP>

    var transaction: Transaction!

    func archiveEncodedTransaction() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(transaction.encoded)
    }

    func unarchive(archive: NSData) -> Transaction? {
        return Transaction.decode(NSKeyedUnarchiver.unarchiveObjectWithData(archive))
    }

    func test__transaction_encodes() {
        transaction = Transaction(base: 100, quote: FXQuote(rate: 1.2))
        XCTAssertEqual(unarchive(archiveEncodedTransaction())!.base, 100)
    }
}
