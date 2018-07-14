//
//  URLComponents+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension URLComponents {
    public init?(url: URL, parameters: [String : String]) {
        self.init(url: url, resolvingAgainstBaseURL: true)
        query = parameters.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
    }
}
