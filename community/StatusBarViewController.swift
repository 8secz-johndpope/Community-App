//
//  StatusBarViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

protocol StatusBarViewController: AnyObject {
    var scrollView: UIScrollView { get }
    var statusBarBackground: ShadowView { get }
    var showStatusBarBackground: Bool { set get }
    var additionalContainerOffset: CGFloat { get }
}

extension StatusBarViewController {
    
    var additionalContainerOffset: CGFloat {
        return 0
    }
    
}

extension StatusBarViewController where Self: UIViewController {
    
    func updateStatusBarBackground() {
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
            self.statusBarBackground.alpha = self.showStatusBarBackground ? 1 : 0
        }
    }
    
}

extension StatusBarViewController {
    
    func check(containerView: UIView, in viewController: UIViewController) {
        let showStatusBarBackground = ((viewController.view.convert(containerView.frame, from: scrollView).minY + additionalContainerOffset) < viewController.view.safeInsets.top)
        
        if self.showStatusBarBackground != showStatusBarBackground {
            self.showStatusBarBackground = showStatusBarBackground
        }
    }
    
}
