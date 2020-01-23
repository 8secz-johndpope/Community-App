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
    
    private let titleLabel     = UILabel()
    private let chevronView    = UILabel()
    private let lineView       = UIView()
    private let contentView    = SelfSizingTextView()
    private let scriptureStack = UIStackView()
    
    private var infoConstraint = NSLayoutConstraint()
    
    private var scripture: [String : String] = [:]
    
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
        }
        
        let stackBackground = UIView(superview: self).customize {
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.pinTop(to: contentView, .bottom)
            $0.backgroundColor = .backgroundAlt
        }
        
        scriptureStack.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.pinTop(to: contentView, .bottom)
            $0.alignment = .fill
            $0.distribution = .equalSpacing
            $0.spacing = .padding
            $0.axis = .vertical
            
            infoConstraint = $0.constrain(.bottom, to: self, .bottom, plus: -.padding, atPriority: .required - 1)
            infoConstraint.isActive = false
        }
        
        stackBackground.pinBottom(to: self, atPriority: .required - 5)
        
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
        
        let parameters: [ESV.Parameter] = ESV.Parameter.default + [
            .includeReferences(false),
            .includeVerseNumbers(false),
            .includeFirstVerseNumbers(false),
        ]
        
        let processor = SerialProcessor()
        
        for reference in question.references {
            processor.enqueue { [weak self] dequeue in
                ESV.fetch(endpoint: .text, reference: reference, parameters: parameters) { result in
                    if let value = result.value, let passage = value.passages.first {
                        self?.scripture[value.canonical] = passage.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    dequeue()
                }
            }
        }
        
        processor.enqueue { [weak self] dequeue in
            DispatchQueue.main.async {
                guard let self = self else { return }
                for (reference, passage) in self.scripture {
                    QuestionScriptureView(reference: reference, passage: passage).add(toStackview: self.scriptureStack)
                }
            }
            dequeue()
        }
    }
    
}

final class QuestionScriptureView: View {
    
    private let reference: String
    private let passage: String
    
    private let referenceLabel = UILabel()
    private let passageView = SelfSizingTextView()
    private let lineView = UIView()
    
    required init(reference: String, passage: String) {
        self.reference = reference
        self.passage = passage
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        
        backgroundColor = .backgroundAlt
        
        referenceLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.pinTop(to: self).constrainSize(toFit: .vertical)
            $0.numberOfLines = 0
            $0.font = .karla(.bold, size: 14)
            $0.textColor = .text
            $0.text = reference
        }
        
        passageView.add(toSuperview: self).customize {
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.pinTop(to: referenceLabel, .bottom).pinBottom(to: self)
            $0.backgroundColor = .backgroundAlt
            $0.textContainerInset = UIEdgeInsets(top: 8, bottom: 0, left: 8, right: 0)
            $0.isEditable = false
            $0.isSelectable = true
            $0.linkTextAttributes = [.foregroundColor : UIColor.link]
            $0.attributedText = passage.attributed.font(.karla(.italic, size: 14)).color(.text).lineSpacing(5)
        }
        
        lineView.add(toSuperview: self).customize {
            $0.pinLeading(to: self).constrainWidth(to: 3)
            $0.pinTop(to: passageView, plus: 8).pinBottom(to: passageView)
            $0.backgroundColor = .blockQuote
        }
        
    }
    
}
