//
//  UIScrollView+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

extension UIScrollView {
    
    var adjustedOffset: CGPoint {
        if #available(iOS 11.0, *) {
            return CGPoint(x: contentOffset.x, y: contentOffset.y + adjustedContentInset.top)
        }
        else {
            return CGPoint(x: contentOffset.x, y: contentOffset.y + contentInset.top)
        }
    }
    
    var currentIndex: Int {
        return Int((contentOffset.x / width) + 0.5)
    }
    
    func setContentOffset(x: CGFloat, y: CGFloat, animated: Bool = true) {
        setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
    
    var adjustedInset: UIEdgeInsets {
        return UIEdgeInsets(
            top: contentInset.top + safeInsets.top,
            left: contentInset.left + safeInsets.left,
            bottom: contentInset.bottom + safeInsets.bottom,
            right: contentInset.right + safeInsets.right
        )
    }
    
}
