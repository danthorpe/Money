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

class FXErrorTests: XCTestCase {

    func test__fx_error__equality() {
        XCTAssertNotEqual(FXError.NoData, FXError.RateNotFound("whatever"))
    }
}

class FXProviderTests: XCTestCase {

    func createGarbageData() -> NSData {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("Troll", ofType: "png")
        let data = NSData(contentsOfFile: path!)
        return data!
    }

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

