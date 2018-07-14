//
//  UIEdgeInsets+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

extension UIEdgeInsets {
    
    init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
    
}
