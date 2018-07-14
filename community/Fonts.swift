//
//  Fonts.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

extension UIFont {
    
    static func openSans(_ weight: OpenSans, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size)!
    }
    
    static func bold(size: CGFloat) -> UIFont {
        return .openSans(.bold, size: size)
    }
    
    static func boldItalic(size: CGFloat) -> UIFont {
        return .openSans(.boldItalic, size: size)
    }
    
    static func extraBold(size: CGFloat) -> UIFont {
        return .openSans(.extraBold, size: size)
    }
    
    static func extraBoldItalic(size: CGFloat) -> UIFont {
        return .openSans(.extraBoldItalic, size: size)
    }
    
    static func italic(size: CGFloat) -> UIFont {
        return .openSans(.italic, size: size)
    }
    
    static func light(size: CGFloat) -> UIFont {
        return .openSans(.light, size: size)
    }
    
    static func lightItalic(size: CGFloat) -> UIFont {
        return .openSans(.lightItalic, size: size)
    }
    
    static func regular(size: CGFloat) -> UIFont {
        return .openSans(.regular, size: size)
    }
    
    static func semiBold(size: CGFloat) -> UIFont {
        return .openSans(.semiBold, size: size)
    }
    
    static func semiBoldItalic(size: CGFloat) -> UIFont {
        return .openSans(.semiBoldItalic, size: size)
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
    
    enum OpenSans: String {
        case bold            = "OpenSans-Bold"
        case boldItalic      = "OpenSans-BoldItalic"
        case extraBold       = "OpenSans-ExtraBold"
        case extraBoldItalic = "OpenSans-ExtraBoldItalic"
        case italic          = "OpenSans-Italic"
        case light           = "OpenSans-Light"
        case lightItalic     = "OpenSans-LightItalic"
        case regular         = "OpenSans-Regular"
        case semiBold        = "OpenSans-SemiBold"
        case semiBoldItalic  = "OpenSans-SemiBoldItalic"
    }
    
}
