//
//  UIScrollView+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

extension UIScrollView {
    
    var adjustedOffset: CGPoint {
        return CGPoint(x: contentOffset.x, y: contentOffset.y + adjustedContentInset.top)
    }
    
    var currentIndex: Int {
        return Int((contentOffset.x / width) + 0.5)
    }
    
    func setContentOffset(x: CGFloat, y: CGFloat, animated: Bool = true) {
        setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
    
    var adjustedInset: UIEdgeInsets {
        return UIEdgeInsets(
            top: contentInset.top + safeAreaInsets.top,
            left: contentInset.left + safeAreaInsets.left,
            bottom: contentInset.bottom + safeAreaInsets.bottom,
            right: contentInset.right + safeAreaInsets.right
        )
    }
    
}
