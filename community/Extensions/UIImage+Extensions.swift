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
    
    var square: UIImage {
        let width = size.width
        let height = size.height
        let length = min(width, height)

        let rect = CGRect(
            x: (width - length)/2 * scale,
            y: (height - length)/2 * scale,
            width: length * scale,
            height: length * scale
        )

        return cgImage?.cropping(to: rect).flatMap(UIImage.init(cgImage:)) ?? self
    }
    
}
