//
//  Colors.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

extension UIColor {
    
    static let dark     = #colorLiteral(red: 0.1529411765, green: 0.1843137255, blue: 0.2196078431, alpha: 1)  // #272F38 #colorLiteral(red: 0.1843137255, green: 0.2509803922, blue: 0.3137254902, alpha: 1)  // #2F4050
    static let lightest = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9764705882, alpha: 1)  // #F3F3F9
    static let light    = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)  // #D8D8D8
    static let orange   = #colorLiteral(red: 0.9607843137, green: 0.4392156863, blue: 0.3882352941, alpha: 1)  // #F57063
    static let dimmer   = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 0.4951435811)  // #111111 (50% alpha)
    
}

struct Gradient {
    var colors: [UIColor]
    
    init(colors: UIColor...) {
        self.colors = colors
    }
    
    var cgColors: [CGColor] {
        return colors.map { $0.cgColor }
    }
    
    static let shelf     = Gradient(colors: .lightest, .white)
    static let empty     = Gradient(colors: #colorLiteral(red: 0.9294117647, green: 0.9450980392, blue: 0.968627451, alpha: 1), #colorLiteral(red: 0.7882352941, green: 0.8431372549, blue: 0.9137254902, alpha: 1))   // #EDF1F7, #C9D7E9
    static let emptyDark = Gradient(colors: #colorLiteral(red: 0.7294117647, green: 0.8, blue: 0.8901960784, alpha: 1), #colorLiteral(red: 0.862745098, green: 0.8941176471, blue: 0.9411764706, alpha: 1))   // #BACCE3, #DCE4F0
}
