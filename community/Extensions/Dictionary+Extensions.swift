//
//  JSON.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation
import Alexandria

protocol Initializable {
    init?(json: [String : Any])
}

extension Dictionary where Key == String, Value: Any {
    
    func initialize<I: Initializable>(forKey key: Key) -> I? {
        return I(json: dictionary(forKey: key))
    }
    
    func `enum`<R: RawRepresentable>(forKey key: Key) -> R? where R.RawValue == String {
        return string(forKey: key).flatMap { R(rawValue: $0) }
    }
    
    func `enum`<R: RawRepresentable>(forKey key: Key) -> R? where R.RawValue == Int {
        return int(forKey: key).flatMap { R(rawValue: $0) }
    }
    
    func string(forKey key: Key) -> String? {
        return self[key] as? String
    }
    
    func int(forKey key: Key) -> Int? {
        return self[key] as? Int
    }
    
    func double(forKey key: Key) -> Double? {
        if let double = self[key] as? Double {
            return double
        }
        else if let int = int(forKey: key) {
            return Double(int)
        }
        else {
            return nil
        }
    }
    
    func float(forKey key: Key) -> Float? {
        if let float = self[key] as? Float {
            return float
        }
        else if let double = double(forKey: key) {
            return Float(double)
        }
        else {
            return nil
        }
    }
    
    func cgFloat(forKey key: Key) -> CGFloat? {
        if let cgFloat = self[key] as? CGFloat {
            return cgFloat
        }
        else if let float = float(forKey: key) {
            return CGFloat(float)
        }
        else {
            return nil
        }
    }
    
    func bool(forKey key: Key) -> Bool? {
        if let bool = self[key] as? Bool {
            return bool
        }
        else if let int = int(forKey: key) {
            return Bool(exactly: NSNumber(value: int))
        }
        else {
            return nil
        }
    }
    
    func date(forKey key: Key, formatter: DateFormatter) -> Date? {
        return string(forKey: key).flatMap(formatter.date(from:))
    }
    
    func color(forKey key: Key) -> UIColor? {
        return string(forKey: key).flatMap { UIColor(hexString: $0) }
    }
    
    func url(forKey key: Key, encode: Bool = false) -> URL? {
        guard let urlString = string(forKey: key) else { return nil }
        
        if encode {
            return urlString.addingPercentEncoding(withAllowedCharacters: .urlAllowed).flatMap(URL.init(string:))
        }
        else {
            return URL(string: urlString)
        }
    }
    
    func array(forKey key: Key) -> [Any] {
        return (self[key] as? [Any]) ?? []
    }
    
    func array<I: Initializable>(forKey key: Key) -> [I] {
        return array(forKey: key).dictionaries.compactMap { I(json: $0) }
    }
    
    func dictionary(forKey key: Key) -> [String : Any] {
        return (self[key] as? [String : Any]) ?? [:]
    }
    
    func dictionary(forKeys keys: Key...) -> [String : Any] {
        guard !keys.isEmpty else { return [:] }
        
        var dictionary = self.dictionary(forKey: keys[0])
        
        for key in keys.dropFirst() {
            dictionary = dictionary.dictionary(forKey: key)
        }
        
        return dictionary
    }
    
}

extension Dictionary where Key == String, Value: Any {
    
    var strings: [String : String] {
        return (self as? [String : String]) ?? [:]
    }
    
    var doubles: [String : Double] {
        return (self as? [String : Double]) ?? [:]
    }
    
}

extension Array where Element == Any {
    
    var strings: [String] {
        return (self as? [String]) ?? []
    }
    
    var integers: [Int] {
        return (self as? [Int]) ?? []
    }
    
    var doubles: [Double] {
        return (self as? [Double]) ?? []
    }
    
    var dictionaries: [[String : Any]] {
        return (self as? [[String : Any]]) ?? []
    }
    
}

extension Array {
    
    func batch(size: Int) -> [[Element]] {
        var batches: [[Element]] = []
        let indices = stride(from: startIndex, to: count, by: size)
        
        for index in indices {
            let nextIndex = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            batches.append(Array(self[index ..< nextIndex]))
        }
        
        return batches
    }
    
}

extension Dictionary {
    
    static func flatten(_ dictionary: [Key : Value?]) -> [Key : Value] {
        var dict: [Key : Value] = [:]
        for (key, value) in dictionary {
            if let value = value {
                dict[key] = value
            }
        }
        return dict
    }
    
}
