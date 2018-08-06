//
//  NSLayoutManager+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 8/4/18.
//

import UIKit

extension NSLayoutManager {
    
    private func ranges(forAttachment attachment: NSTextAttachment) -> [NSRange]? {
        guard let attributedString = self.textStorage else { return nil }
        
        let range = NSRange(location: 0, length: attributedString.length)
        
        var refreshRanges: [NSRange] = []
        
        attributedString.enumerateAttribute(.attachment, in: range, options: []) { value, effectiveRange, _ in
            guard let foundAttachment = value as? NSTextAttachment, foundAttachment == attachment else { return }
            refreshRanges.append(effectiveRange)
        }
        
        if refreshRanges.isEmpty {
            return nil
        }
        
        return refreshRanges
    }
    
    func setNeedsLayout(forAttachment attachment: NSTextAttachment) {
        guard let ranges = ranges(forAttachment: attachment) else { return }
        
        ranges.reversed().forEach {
            invalidateLayout(forCharacterRange: $0, actualCharacterRange: nil)
            invalidateDisplay(forCharacterRange: $0)
        }
    }
    
    func setNeedsDisplay(forAttachment attachment: NSTextAttachment) {
        guard let ranges = ranges(forAttachment: attachment) else { return }
        ranges.reversed().forEach { invalidateDisplay(forCharacterRange: $0) }
    }
}
