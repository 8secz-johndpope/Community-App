//
//  URLRequest+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension URLRequest {
    
    init(url: URL, parameters: [String : String]) {
        let url = URL(base: url, parameters: parameters)
        self.init(url: url)
    }
    
    mutating func set(httpHeaders: [String : String]) {
        for (field, value) in httpHeaders {
            setValue(value, forHTTPHeaderField: field)
        }
    }
    
}
