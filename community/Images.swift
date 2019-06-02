//
//  Images.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

enum Icon: Int {
    case home         = 0xf015
    case list         = 0xf03a
    case video        = 0xf03d
    case cog          = 0xf013
    case close        = 0xf00d
    case play         = 0xf04b
    case pause        = 0xf04c
    case community    = 0xf0c0
    case child        = 0xf1ae
    case decision     = 0xf0ec
    case dollar       = 0xf155
    case money        = 0xf3d1
    case infoCircle   = 0xf05a
    case chevronRight = 0xf054
    case chevronLeft  = 0xf053
    case search       = 0xf002
    case angleRight   = 0xf105
    case safari       = 0xf14e
    case article      = 0xf1ea
    case headphone    = 0xf58f
    case file         = 0xf15c
    case notification = 0xf77f
    
    var string: String {
        return String(format: "%C", rawValue)
    }
}

extension Icon {
    
    init?(string: String?) {
        guard let string = string else { return nil }
        
        var value: UInt32 = 0
        let scanner = Scanner(string: string)
        scanner.scanHexInt32(&value)
        
        self.init(rawValue: Int(value))
    }
    
}
