//
//  CALayer+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import UIKit

extension CALayer {
    
    convenience init(superlayer: CALayer) {
        self.init()
        superlayer.addSublayer(self)
    }
    
    @discardableResult
    func add(toSuperlayer superlayer: CALayer) -> Self {
        superlayer.addSublayer(self)
        return self
    }
    
}
