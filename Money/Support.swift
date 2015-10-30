//
//  Support.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

extension Int: BooleanType {

    public var boolValue: Bool {
        switch self {
        case 0: return false
        default: return true
        }
    }
}

