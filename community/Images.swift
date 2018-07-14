//
//  Images.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

enum Icon: Int {
    case home  = 0xf015
    case list  = 0xf03a
    case video = 0xf03d
    case cog   = 0xf013
    
    var string: String {
        return String(format: "%C", rawValue)
    }
}
