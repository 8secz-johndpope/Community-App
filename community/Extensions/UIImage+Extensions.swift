//
//  UIImage+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 8/4/18.
//

import UIKit

extension UIImage {
    
    static func placeholder(color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        defer { UIGraphicsEndImageContext() }
        
        color.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}
