//
//  CharacterSet+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation

extension CharacterSet {
    
    public static var urlAllowed: CharacterSet {
        return CharacterSet()
            .union(.urlFragmentAllowed)
            .union(.urlHostAllowed)
            .union(.urlPasswordAllowed)
            .union(.urlQueryAllowed)
            .union(.urlUserAllowed)
            .union(.urlPathAllowed)
    }
    
}
