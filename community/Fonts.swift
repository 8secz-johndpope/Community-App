//
//  Fonts.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

extension UIFont {
    
    static func karla(_ weight: Karla, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size)!
    }
    
    static func crimsonText(_ weight: CrimsonText, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size)!
    }
    
    static var header: UIFont {
        return .crimsonText(.semiBold, size: 35)
    }
    
    static var subHeader: UIFont {
        return .karla(.regular, size: 16)
    }
    
    static var title: UIFont {
        return .karla(.bold, size: 25)
    }
    
    static func bold(size: CGFloat) -> UIFont {
        return .karla(.bold, size: size)
    }
    
    static func boldItalic(size: CGFloat) -> UIFont {
        return .karla(.boldItalic, size: size)
    }
    
    static func italic(size: CGFloat) -> UIFont {
        return .karla(.italic, size: size)
    }
    
    static func regular(size: CGFloat) -> UIFont {
        return .karla(.regular, size: size)
    }
    
    static func fontAwesome(_ weight: FontAwesome, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size)!
    }
    
}

extension UIFont {
    
    enum FontAwesome: String {
        case regular = "FontAwesome5ProRegular"
        case solid   = "FontAwesome5ProSolid"
        case light   = "FontAwesome5ProLight"
    }
    
    enum CrimsonText: String {
        case bold            = "CrimsonText-Bold"
        case boldItalic      = "CrimsonText-BoldItalic"
        case italic          = "CrimsonText-Italic"
        case regular         = "CrimsonText-Regular"
        case semiBold        = "CrimsonText-SemiBold"
        case semiBoldItalic  = "CrimsonText-SemiBoldItalic"
    }
    
    enum Karla: String {
        case bold       = "Karla-Bold"
        case boldItalic = "Karla-BoldItalic"
        case italic     = "Karla-Italic"
        case regular    = "Karla-Regular"
    }
    
}
