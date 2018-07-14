//
//  UILabel+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

extension UILabel {
    
    func set(icon: Icon) {
        text = icon.string
    }
    
    func fontToFitHeight(minSize: CGFloat, maxSize: CGFloat) -> UIFont {
        
        guard let text = text else { return font }
        
        var minSize = minSize
        var maxSize = maxSize
        
        var fontSizeAverage: CGFloat = 0
        var textAndLabelHeightDiff: CGFloat = 0
        
        while (minSize <= maxSize) {
            
            fontSizeAverage = minSize + (maxSize - minSize) / 2
            
            // Abort if text happens to be nil
            guard !text.isEmpty else {
                break
            }
            
            let labelHeight = frame.size.height
            
            let testStringHeight = text.ns.size(withAttributes: [.font: font.withSize(fontSizeAverage)]).height
            
            textAndLabelHeightDiff = labelHeight - testStringHeight
            
            if fontSizeAverage == minSize || fontSizeAverage == maxSize {
                if textAndLabelHeightDiff < 0 {
                    return font.withSize(fontSizeAverage - 1)
                }
                return font.withSize(fontSizeAverage)
            }
            
            if (textAndLabelHeightDiff < 0) {
                maxSize = fontSizeAverage - 1
                
            } else if (textAndLabelHeightDiff > 0) {
                minSize = fontSizeAverage + 1
                
            } else {
                return font.withSize(fontSizeAverage)
            }
        }
        
        return font.withSize(fontSizeAverage)
    }
    
}
