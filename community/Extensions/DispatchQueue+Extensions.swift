//
//  DispatchQueue+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/15/18.
//

import Foundation

extension DispatchQueue {
    
    static func onMain(execute closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        }
        else {
            main.async(execute: closure)
        }
    }
    
}
