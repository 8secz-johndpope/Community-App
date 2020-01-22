//
//  HeaderViewController.swift
//  community
//
//  Created by Jonathan Landon on 1/21/20.
//

import UIKit
import Diakoneo

protocol HeaderViewController: AnyObject {
    var scrollView: UIScrollView { get }
    var shadowView: ShadowView { get }
    var headerView: UIView { get }
    var headerLabel: UILabel { get }
    var isShowingHeaderLabel: Bool { set get }
}

extension HeaderViewController where Self: ViewController {
    
    func setupHeader(in view: UIView, title: String?) {
        headerView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinBottomToTopSafeArea(in: self, plus: 50)
            $0.backgroundColor = .background
            $0.alpha = 0
            $0.isHidden = true
        }
        
        UIView(superview: headerView).customize {
            $0.pinLeading(to: headerView).pinTrailing(to: headerView)
            $0.pinBottom(to: headerView).constrainHeight(to: 1)
            $0.backgroundColor = .tabBarLine
        }
        
        shadowView.add(toSuperview: view, behind: headerView).customize {
            $0.pinLeading(to: headerView).pinTrailing(to: headerView)
            $0.pinTop(to: headerView).pinBottom(to: headerView)
            $0.backgroundColor = .background
            $0.shadowOpacity = 0.2
            $0.alpha = 0
        }
        
        headerLabel.add(toSuperview: headerView).customize {
            $0.pinBottom(to: headerView).constrainHeight(to: 50)
            $0.pinCenterX(to: headerView).constrainSize(toFit: .horizontal)
            $0.font = .bold(size: 16)
            $0.textColor = .text
            $0.text = title
        }
    }
    
    func didScroll() {
        shadowView.alpha = scrollView.adjustedOffset.y.map(from: 40...60, to: 0...1).limited(0, 1)
        
        if scrollView.adjustedOffset.y > 40 {
            if !isShowingHeaderLabel {
                isShowingHeaderLabel = true
                UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                    self.headerView.alpha = 1
                    self.setNeedsStatusBarAppearanceUpdate()
                }, completion: nil)
            }
        }
        else {
            if isShowingHeaderLabel {
                isShowingHeaderLabel = false
                UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                    self.headerView.alpha = 0
                    self.setNeedsStatusBarAppearanceUpdate()
                }, completion: nil)
            }
        }
    }
    
}
