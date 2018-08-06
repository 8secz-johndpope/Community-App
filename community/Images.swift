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
    
    var string: String {
        return String(format: "%C", rawValue)
    }
}
