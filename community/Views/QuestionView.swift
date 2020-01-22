//
//  QuestionView.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import UIKit
import Diakoneo

final class QuestionView: View {
    
    private let question: Contentful.Question
    private var isExpanded = false
    
    private let titleLabel  = UILabel()
    private let chevronView = UILabel()
    private let lineView    = UIView()
    private let contentView = SelfSizingTextView()
    
    private var infoConstraint = NSLayoutConstraint()
    
    required init(question: Contentful.Question) {
        self.question = question
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        borderColor = .separator
        chevronView.borderColor = .separator
    }
    
    override func setup() {
        super.setup()
        
        clipsToBounds = true
        backgroundColor = .background
        cornerRadius = 8
        borderColor = .separator
        borderWidth = 1
        
        titleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding)
            $0.pinTop(to: self, plus: .padding).constrainSize(toFit: .vertical)
            $0.pinBottom(to: self, plus: -.padding, atPriority: .required - 2)
            $0.numberOfLines = 0
            $0.font = .crimsonText(.semiBold, size: 30)
            $0.textColor = .text
        }
        
        chevronView.add(toSuperview: self).customize {
            $0.pinLeading(to: titleLabel, .trailing, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.pinCenterY(to: titleLabel)
            $0.cornerRadius = 15
            $0.borderColor = .separator
            $0.borderWidth = 1
            $0.textAlignment = .center
            $0.font = .fontAwesome(.light, size: 25)
            $0.textColor = .separator
            $0.text = String(format: " %C", Icon.angleRight.rawValue)   // include half-space character for proper alignment
        }
        
        lineView.add(toSuperview: self).customize {
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.pinTop(to: titleLabel, .bottom, plus: .padding).constrainHeight(to: 1)
            $0.backgroundColor = .separator
        }
        
        contentView.add(toSuperview: self).customize {
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.pinTop(to: lineView, .bottom)
            $0.backgroundColor = .backgroundAlt
            $0.textColor = .text
            $0.textContainerInset = UIEdgeInsets(inset: .textInset)
            $0.isEditable = false
            $0.isSelectable = true
            $0.linkTextAttributes = [.foregroundColor : UIColor.link]
            
            infoConstraint = $0.constrain(.bottom, to: self, .bottom, atPriority: .required - 1)
            infoConstraint.isActive = false
        }
        
        configure()
        
        addGesture(type: .tap) { [weak self] _ in self?.toggle() }
    }
    
    private func toggle() {
        isExpanded.toggle()
        
        self.infoConstraint.isActive = isExpanded
        
        if isExpanded {
            Analytics.viewed(question: question)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
            if self.isExpanded {
                self.chevronView.transform = .rotate(.pi/2)
            }
            else {
                self.chevronView.transform = .identity
            }
            
            UIViewController.current?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func configure() {
        titleLabel.text = question.question
        contentView.attributedText = question.info.renderMarkdown(withBaseFont: .regular(size: 14))
    }
    
}
