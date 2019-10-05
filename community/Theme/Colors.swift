//
//  Colors.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import Diakoneo

extension UIColor {
    
    var isLightColor: Bool {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let colorBrightness = ((r * 299) + (g * 587) + (b * 114)) / 1000

        return !(colorBrightness < 0.5)
    }
    
    convenience init(_ light: UIColor, _ dark: UIColor) {
        if #available(iOS 13, *) {
            self.init {
                switch $0.userInterfaceStyle {
                case .dark:        return dark
                case .light:       return light
                case .unspecified: return light
                @unknown default:  return light
                }
            }
        }
        else {
            self.init(cgColor: light.cgColor)
        }
    }
    
}

extension UIColor {
    
//    static let dark            = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)  // #323232
//    static let grayBlue        = #colorLiteral(red: 0.1529411765, green: 0.1843137255, blue: 0.2196078431, alpha: 1)  // #272F38
//    static let blockQuote      = #colorLiteral(red: 0.4941176471, green: 0.5058823529, blue: 0.5215686275, alpha: 1)  // #7E8185
//    static let loading         = #colorLiteral(red: 0.7294117647, green: 0.8, blue: 0.8901960784, alpha: 1)  // #BACCE3
//    static let light           = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)  // #D8D8D8
//    static let lightest        = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9764705882, alpha: 1)  // #F3F3F9
//    static let lightBackground = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9843137255, alpha: 1)  // #F9F9FB
    
    // MARK: - Static Colors
    
    private static let mineShaft       = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)  // #323232
    private static let gray            = #colorLiteral(red: 0.4941176471, green: 0.5058823529, blue: 0.5215686275, alpha: 1)  // #7E8185
    private static let beauBlue        = #colorLiteral(red: 0.7294117647, green: 0.8, blue: 0.8901960784, alpha: 1)  // #BACCE3
    private static let iron            = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)  // #D8D8D8
    private static let whiteSmoke      = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9764705882, alpha: 1)  // #F3F3F9
    private static let alabaster       = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9843137255, alpha: 1)  // #F9F9FB
    private static let nero            = #colorLiteral(red: 0.1529411765, green: 0.1529411765, blue: 0.1529411765, alpha: 1)  // #272727
    private static let onyx            = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)  // #111111
    private static let darkGray        = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)  // #555555
    private static let darkJungleGreen = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)  // #1C1C1E
    private static let pictonBlue      = #colorLiteral(red: 0.2509803922, green: 0.6235294118, blue: 0.9725490196, alpha: 1)  // #409FF8
    private static let bittersweet     = #colorLiteral(red: 0.9607843137, green: 0.4392156863, blue: 0.3882352941, alpha: 1)  // #F57063
    private static let halfbaked       = #colorLiteral(red: 0.5490196078, green: 0.7294117647, blue: 0.8196078431, alpha: 1)  // #8CBAD1
    private static let sanJuan         = #colorLiteral(red: 0.1960784314, green: 0.3058823529, blue: 0.4117647059, alpha: 1)  // #324E69
    private static let doveGray        = #colorLiteral(red: 0.4235294118, green: 0.431372549, blue: 0.4235294118, alpha: 1)  // #6C6E6C
    private static let sandal          = #colorLiteral(red: 0.6588235294, green: 0.5647058824, blue: 0.4352941176, alpha: 1)  // #A8906F
    private static let shingleFawn     = #colorLiteral(red: 0.431372549, green: 0.3450980392, blue: 0.2235294118, alpha: 1)  // #6E5839
    
    static let dimmer = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 0.4951435811)  // #111111 (50% alpha)
    
    // MARK: - Dynamic Colors
    
    static let text                  = UIColor(.mineShaft, .alabaster)
    static let link                  = UIColor(.halfbaked, .pictonBlue)
    
    static let blockQuote            = UIColor(.gray, .iron)
    static let loading               = UIColor(.beauBlue, .gray)
    
    static let background            = UIColor(.alabaster, .black)
    static let backgroundAlt         = UIColor(.whiteSmoke, .nero)
    static let headerBackground      = UIColor(.sanJuan, .onyx)
    static let headerText            = UIColor(.alabaster, .alabaster)
    static let headerTextHighlighted = UIColor(.iron, .iron)
    static let separator             = UIColor(.iron, .darkJungleGreen)
    static let tabSelected           = UIColor(.sanJuan, .white)
    static let tabUnselected         = UIColor(.iron, .darkGray)
    static let tabBarLine            = UIColor(.clear, .backgroundAlt)
    static let questionsTint         = UIColor(.sandal, .shingleFawn)
    static let notificationsButton   = UIColor(.sanJuan, .onyx)
    static let postOverlay           = UIColor(.clear, .dimmer)
    
}

extension Gradient {
    static let shelf     = Gradient(colors: .backgroundAlt, .background)
    static let empty     = Gradient(colors: #colorLiteral(red: 0.9294117647, green: 0.9450980392, blue: 0.968627451, alpha: 1), #colorLiteral(red: 0.7882352941, green: 0.8431372549, blue: 0.9137254902, alpha: 1))   // #EDF1F7, #C9D7E9
    static let emptyDark = Gradient(colors: #colorLiteral(red: 0.7294117647, green: 0.8, blue: 0.8901960784, alpha: 1), #colorLiteral(red: 0.862745098, green: 0.8941176471, blue: 0.9411764706, alpha: 1))   // #BACCE3, #DCE4F0
}
