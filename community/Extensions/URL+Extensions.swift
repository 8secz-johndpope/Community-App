//
//  URL+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension URL {
    
    public init(base: URL, parameters: [String : String]) {
        guard let components = URLComponents(url: base, parameters: parameters), let url = components.url
            else { fatalError("URL could not be created: \(base), with parameters: \(parameters)") }
        
        self = url
    }
    
}
