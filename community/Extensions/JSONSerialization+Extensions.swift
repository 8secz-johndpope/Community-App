//
//  JSONSerialization+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation

extension JSONSerialization {
    
    public static func dictionary(from data: Data?) -> [String : Any] {
        guard
            let data = data,
            let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let json = object as? [String : Any]
        else { return [:] }
        
        return json
    }
    
    public static func array(from data: Data?) -> [[String : Any]] {
        guard
            let data = data,
            let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let json = object as? [[String : Any]]
        else { return [] }
        
        return json
    }
    
}
