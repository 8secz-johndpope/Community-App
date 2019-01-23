//
//  SettingsViewController.swift
//  community
//
//  Created by Jonathan Landon on 8/8/18.
//

import UIKit
import Alexandria

final class SettingsViewController: ViewController {
    
    private let scrollView    = UIScrollView()
    private let containerView = UIView()
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .lightBackground
        
        scrollView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .lightBackground
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
        }
        
        containerView.add(toSuperview: scrollView).customize {
            $0.constrainEdgesToSuperview()
            $0.constrainWidth(to: view)
            $0.backgroundColor = .lightBackground
        }
        
        UILabel(superview: containerView).customize {
            $0.pinLeading(to: containerView, plus: .padding).pinTrailing(to: containerView, plus: -.padding)
            $0.pinTop(to: containerView, plus: 60).pinBottom(to: containerView).constrainSize(toFit: .vertical)
            $0.font = .header
            $0.textColor = .dark
            $0.text = "Settings"
        }
    }
    
}
