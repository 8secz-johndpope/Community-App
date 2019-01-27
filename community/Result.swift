//
//  Result.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

enum Result<Value, Error: Swift.Error> {
    case value(Value)
    case error(Error)
    
    var value: Value? {
        switch self {
        case .value(let value): return value
        case .error:            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .value:            return nil
        case .error(let error): return error
        }
    }
}
