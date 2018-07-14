//
//  Result.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)
    
    var value: Value? {
        switch self {
        case .success(let value): return value
        case .failure:            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .success:            return nil
        case .failure(let error): return error
        }
    }
}
