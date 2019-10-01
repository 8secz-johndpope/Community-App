//
//  Images.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Diakoneo

extension Icon {
    
    init?(string: String?) {
        guard let string = string else { return nil }
        
        var value: UInt32 = 0
        let scanner = Scanner(string: string)
        scanner.scanHexInt32(&value)
        
        self.init(rawValue: Int(value))
    }
    
    func image(fontSize: CGFloat, color: UIColor, weight: UIFont.FontAwesome) -> UIImage? {
        return UILabel().customize {
            $0.font = .fontAwesome(weight, size: fontSize)
            $0.set(icon: self)
            $0.textColor = color
            $0.sizeToFit()
        }.snapshot()
    }
    
}
