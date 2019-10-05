//
//  CommunityQuestionsView.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import UIKit
import Diakoneo

final class CommunityQuestionsView: View {
    
    private var communityQuestions: Contentful.CommunityQuestions?
    
    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView     = StackView(axis: .vertical)
    
    override func setup() {
        super.setup()
        
        backgroundColor = .background
        
        titleLabel.add(toSuperview: self).customize {
            $0.pinTop(to: self)
            $0.pinLeading(to: self, plus: .padding).constrainSize(toFit: .vertical, .horizontal)
            $0.backgroundColor = .background
        }
        
        subtitleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom, plus: 5).constrainSize(toFit: .vertical)
            $0.backgroundColor = .background
            $0.numberOfLines = 2
        }
        
        stackView.add(toSuperview: self).customize {
            $0.pinTop(to: subtitleLabel, .bottom).pinBottom(to: self)
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.backgroundColor = .clear
        }
    }
    
    func configure(communityQuestions: Contentful.CommunityQuestions) {
        self.communityQuestions = communityQuestions
        
        titleLabel.attributedText = communityQuestions.title.attributed.font(.crimsonText(.semiBold, size: 25)).color(.text)
        subtitleLabel.attributedText = communityQuestions.info.attributed.font(.subHeader).color(.text)
        
        func number(_ value: Int, text: String, backgroundColor: UIColor) -> UIView {
            let view = UIView().customize {
                $0.backgroundColor = backgroundColor
            }
            
            let number = UILabel(superview: view).customize {
                $0.pinTop(to: view).pinBottom(to: view, atPriority: .required - 1)
                $0.pinLeading(to: view, plus: .padding).constrainWidth(to: 30).constrainHeight(to: 30)
                $0.backgroundColor = .questionsTint
                $0.cornerRadius = 15
                $0.text = "\(value)"
                $0.textColor = .white
                $0.font = .bold(size: 16)
                $0.textAlignment = .center
            }
            
            UILabel(superview:  view).customize {
                $0.pinTop(to: view, plus: 4).pinBottom(to: view, relation: .lessThanOrEqual)
                $0.pinLeading(to: number, .trailing, plus: .padding).pinTrailing(to: view, plus: -.padding)
                $0.constrainSize(toFit: .vertical)
                $0.text = text
                $0.font = .regular(size: 16)
                $0.textColor = .text
                $0.numberOfLines = 0
            }
            
            return view
        }
        
        var elements: [StackView.Element] = []
        
        for (index, question) in communityQuestions.questions.enumerated() {
            elements.append(contentsOf: [
                .view(.background, .padding),
                .custom(QuestionView(number: index + 1, question: question)),
            ])
        }
        
        elements.append(.view(.background, .padding))
        
        stackView.configure(elements: elements)
    }
    
}
