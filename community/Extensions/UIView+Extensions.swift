//
//  UIView+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

extension UIView {
    
    func constrainClose(width: CGFloat = .closeButtonWidth, height: CGFloat = .closeButtonWidth) {
        constrainWidth(to: width).constrainHeight(to: height)
    }
    
    func pinBottomToTopSafeArea(in controller: UIViewController, plus: CGFloat = 0) {
        if #available(iOS 11, *) {
            pinSafely(.bottom, to: controller.view, .top, plus: plus)
        }
        else {
            pinBottom(to: controller.topLayoutGuide, plus: plus)
        }
    }
    
    func textInteraction(_ interaction: UITextItemInteraction, closure: () -> Void) {
        if #available(iOS 13.2, *) {
            closure()
        }
        else if #available(iOS 13, *) {
            if case .presentActions = interaction {
                closure()
            }
        }
        else {
            closure()
        }
    }
    
}

