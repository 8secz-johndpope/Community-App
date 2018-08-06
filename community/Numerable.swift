//
//  Numerable.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import UIKit

protocol Numerable: Comparable {
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
}

extension Numerable {
    
    func map(from old: ClosedRange<Self>, to new: ClosedRange<Self>) -> Self {
        let oldRange = old.upperBound - old.lowerBound
        let newRange = new.upperBound - new.lowerBound
        
        return (self - old.lowerBound) * newRange / oldRange + new.lowerBound
    }
}

extension Double: Numerable {}
extension Float: Numerable {}
extension CGFloat: Numerable {}
extension Int: Numerable {}
extension Int8: Numerable {}
extension Int16: Numerable {}
extension Int32: Numerable {}
extension Int64: Numerable {}
extension UInt: Numerable {}
extension UInt8: Numerable {}
extension UInt16: Numerable {}
extension UInt32: Numerable {}
extension UInt64: Numerable {}
