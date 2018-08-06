//
//  UIGestureRecognizer+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import UIKit

extension UIGestureRecognizer {
    
    var tap: UITapGestureRecognizer? { return self as? UITapGestureRecognizer }
    var longPress: UILongPressGestureRecognizer? { return self as? UILongPressGestureRecognizer }
    var pan: UIPanGestureRecognizer? { return self as? UIPanGestureRecognizer }
    var swipe: UISwipeGestureRecognizer? { return self as? UISwipeGestureRecognizer }
    
}
