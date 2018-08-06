//
//  String+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/25/18.
//

import UIKit

extension String {
    
    func size(boundingWidth: CGFloat = .greatestFiniteMagnitude, boundingHeight: CGFloat = .greatestFiniteMagnitude, font: UIFont, lineSpacing: CGFloat? = nil) -> CGSize {
        
        var attributes: [NSAttributedStringKey : Any] = [.font : font]
        
        if let lineSpacing = lineSpacing {
            attributes[.paragraphStyle] = NSMutableParagraphStyle().customize { $0.lineSpacing = lineSpacing }
        }
        
        return ns.boundingRect(
            with: CGSize(width: boundingWidth, height: boundingHeight),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            attributes: attributes,
            context: nil
            ).size
    }
    
}
