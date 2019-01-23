//
//  Storage.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import Foundation

enum Storage {
    
    enum Key: String {
        case introVideoWasShown = "IntroVideoWasShown"
        
        var domain: String {
            return [Bundle.main.bundleIdentifier ?? "", rawValue].joined(separator: ".")
        }
    }
    
    private static let defaults = UserDefaults.standard
    
    static func clear(_ key: Key) {
        defaults.set(nil, forKey: key.domain)
    }
    
    static func has(_ key: Key) -> Bool {
        return defaults.value(forKey: key.domain) != nil
    }
    
    static func get<T>(_ key: Key) -> T? {
        return defaults.value(forKey: key.domain) as? T
    }
    
    static func set<T>(_ value: T, for key: Key) {
        defaults.set(value, forKey: key.domain)
    }
}
