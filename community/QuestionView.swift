//
//  QuestionView.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import UIKit

final class QuestionView: View {
    
    private let numberLabel   = UILabel()
    private let questionLabel = UILabel()
    private let chevronLabel  = UILabel()
    private let infoView      = SelfSizingTextView()
    
    private var infoConstraint: NSLayoutConstraint?
    private var isExpanded: Bool = false
    
    private let question: Contentful.Question
    
    required init(number: Int, question: Contentful.Question) {
        self.question = question
        super.init(frame: .zero)
        configure(number: number, question: question.question, info: question.info)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = .lightBackground
        clipsToBounds = true
        
        addGesture(type: .tap) { [weak self] _ in self?.toggle() }
        
        numberLabel.add(toSuperview: self).customize {
            $0.pinTop(to: self).pinBottom(to: self, atPriority: .required - 3)
            $0.pinLeading(to: self, plus: .padding).constrainWidth(to: 30).constrainHeight(to: 30)
            $0.backgroundColor = .gold
            $0.cornerRadius = 15
            $0.textColor = .white
            $0.font = .bold(size: 16)
            $0.textAlignment = .center
        }
        
        questionLabel.add(toSuperview: self).customize {
            $0.pinTop(to: self, plus: 4).pinBottom(to: self, relation: .lessThanOrEqual, atPriority: .required - 2)
            $0.pinLeading(to: numberLabel, .trailing, plus: .padding)
            $0.constrainSize(toFit: .vertical)
            $0.font = .regular(size: 16)
            $0.textColor = .dark
            $0.numberOfLines = 0
        }
        
        chevronLabel.add(toSuperview: self).customize {
            $0.pinTop(to: questionLabel).pinBottom(to: questionLabel)
            $0.pinTrailing(to: self).pinLeading(to: questionLabel, .trailing)
            $0.constrainWidth(to: 40)
            $0.font = .fontAwesome(.light, size: 22)
            $0.textColor = .gold
            $0.textAlignment = .center
            $0.set(icon: .angleRight)
        }
        
        infoView.add(toSuperview: self).customize {
            $0.pinTop(to: questionLabel, .bottom, plus: .padding)
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.font = .italic(size: 14)
            $0.textColor = .dark
            $0.backgroundColor = .lightest
            $0.textContainerInset = UIEdgeInsets(inset: .textInset)
            $0.isEditable = false
            $0.isSelectable = true
            $0.linkTextAttributes = [.foregroundColor : UIColor.lightBlue]
            
            infoConstraint = $0.constrain(.bottom, to: self, .bottom, atPriority: .required - 1)
            infoConstraint?.isActive = false
        }
        
        UIView(superview: self).customize {
            $0.pinLeading(to: infoView).pinTrailing(to: infoView)
            $0.pinTop(to: infoView).constrainHeight(to: 1)
            $0.backgroundColor = .light
        }
        
        UIView(superview: self).customize {
            $0.pinLeading(to: infoView).pinTrailing(to: infoView)
            $0.pinBottom(to: infoView).constrainHeight(to: 1)
            $0.backgroundColor = .light
        }
    }
    
    private func toggle() {
        isExpanded.toggle()
        
        self.infoConstraint?.isActive = isExpanded
        
        if isExpanded {
            Analytics.viewed(question: question)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
            if self.isExpanded {
                self.chevronLabel.transform = .rotate(.pi/2)
            }
            else {
                self.chevronLabel.transform = .identity
            }
            
            UIViewController.current?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func configure(number: Int, question: String, info: String) {
        numberLabel.text = "\(number)"
        questionLabel.text = question
        infoView.attributedText = info.renderMarkdown
    }
    
}
