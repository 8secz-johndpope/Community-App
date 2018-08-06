//
//  DateFormatter+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension DateFormatter {
    
    convenience init(format: String) {
        self.init()
        dateFormat = format
    }
    
    static let iso8601      = DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    static let yearMonthDay = DateFormatter(format: "yyyy-MM-dd")
    static let readable     = DateFormatter(format: "MMMM d, yyyy")
}
