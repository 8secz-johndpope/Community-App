//
//  QuestionsViewController.swift
//  community
//
//  Created by Jonathan Landon on 1/20/20.
//

import UIKit
import Diakoneo

final class QuestionsViewController: ViewController {
    
    private let imageView     = UIImageView()
    private let titleLabel    = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10, trailingBuffer: 50)
    private let subtitleLabel = UILabel()
    private let scrollView    = UIScrollView()
    private let containerView = UIView()
    
    private var questionViews: [QuestionView] = []
    
    override func setup() {
        super.setup()
        
        imageView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, plus: 140)
            $0.backgroundColor = .black
        }
        
        titleLabel.add(toSuperview: imageView).customize {
            $0.pinSafely(.top, to: imageView, plus: 44)
            $0.pinLeading(to: imageView, plus: .padding).constrainSize(toFit: .vertical, .horizontal)
            $0.backgroundColor = .clear
        }
        
        subtitleLabel.add(toSuperview: imageView).customize {
            $0.pinLeading(to: imageView, plus: .padding).pinTrailing(to: imageView, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom, plus: 5).constrainSize(toFit: .vertical)
            $0.backgroundColor = .clear
            $0.numberOfLines = 2
        }
        
        scrollView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .clear
            $0.alwaysBounceVertical = true
        }
        
        containerView.add(toSuperview: scrollView).customize {
            $0.constrainEdgesToSuperview(top: 125)
            $0.constrainWidth(to: view)
            $0.backgroundColor = .white
            $0.cornerRadius = 8
        }
        
        UIView(superview: scrollView).customize {
            $0.pinLeading(to: scrollView).pinTrailing(to: scrollView)
            $0.pinTop(to: containerView, .bottom, plus: -20).constrainHeight(to: UIScreen.main.height * 2)
            $0.backgroundColor = .white
        }
        
        Notifier.onCommunityQuestionsChanged.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func reload() {
        guard let communityQuestions = Contentful.LocalStorage.communityQuestions else { return }
        
        titleLabel.attributedText = communityQuestions.title.attributed.font(.header).color(.headerText)
        subtitleLabel.attributedText = communityQuestions.info.attributed.font(.subHeader).color(.headerText)
        
        questionViews.forEach { $0.removeFromSuperview() }
        questionViews = []
        
        for question in communityQuestions.questions {
            let questionView = QuestionView(question: question).add(toSuperview: containerView).customize {
                $0.pinLeading(to: containerView, plus: .padding).pinTrailing(to: containerView, plus: -.padding)

                if let last = questionViews.last {
                    $0.pinTop(to: last, .bottom, plus: .padding)
                }
                else {
                    $0.pinTop(to: containerView, plus: .padding)
                }
            }
            
            questionViews.append(questionView)
        }
        
        questionViews.last?.pinBottom(to: containerView, plus: -.padding)
    }
    
}

extension QuestionsViewController {
    
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
        
        override func setup() {
            super.setup()
            
            clipsToBounds = true
            backgroundColor = .tan
            cornerRadius = 8
            
            titleLabel.add(toSuperview: self).customize {
                $0.pinLeading(to: self, plus: .padding)
                $0.pinTop(to: self, plus: .padding).constrainSize(toFit: .vertical)
                $0.pinBottom(to: self, plus: -.padding, atPriority: .required - 2)
                $0.numberOfLines = 0
                $0.font = .crimsonText(.semiBold, size: 25)
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
                $0.backgroundColor = .tan
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
            contentView.attributedText = question.info.renderMarkdown
        }
        
    }
    
}
