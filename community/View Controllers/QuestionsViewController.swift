//
//  QuestionsViewController.swift
//  community
//
//  Created by Jonathan Landon on 1/20/20.
//

import UIKit
import Diakoneo

final class QuestionsViewController: ViewController, HeaderViewController {
    
    private let titleLabel    = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10, trailingBuffer: 50)
    private let subtitleLabel = UILabel()
    private let containerView = UIView()
    
    private var questionViews: [QuestionView] = []
    
    let scrollView  = UIScrollView()
    let shadowView  = ShadowView()
    let headerView  = UIView()
    let headerLabel = UILabel()
    
    var isShowingHeaderLabel = false
    
    override func viewDidAppearForFirstTime() {
        super.viewDidAppearForFirstTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.headerView.isHidden = false
        }
    }
    
    override func setup() {
        super.setup()
        
        scrollView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.delegate = self
            $0.backgroundColor = .background
            $0.alwaysBounceVertical = true
            $0.showsVerticalScrollIndicator = false
        }
        
        containerView.add(toSuperview: scrollView).customize {
            $0.constrainEdgesToSuperview()
            $0.constrainWidth(to: view)
            $0.backgroundColor = .background
            $0.cornerRadius = 8
        }
        
        titleLabel.add(toSuperview: containerView).customize {
            $0.pinLeading(to: containerView, plus: .padding).pinTrailing(to: containerView, plus: -.padding)
            $0.pinTop(to: containerView, plus: 44).constrainSize(toFit: .vertical, .horizontal)
            $0.backgroundColor = .clear
        }
        
        subtitleLabel.add(toSuperview: containerView).customize {
            $0.pinLeading(to: containerView, plus: .padding).pinTrailing(to: containerView, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom, plus: 5).constrainSize(toFit: .vertical)
            $0.backgroundColor = .clear
            $0.numberOfLines = 2
        }
        
        UIView(superview: scrollView).customize {
            $0.pinLeading(to: scrollView).pinTrailing(to: scrollView)
            $0.pinTop(to: containerView, .bottom, plus: -20).constrainHeight(to: UIScreen.main.height * 2)
            $0.backgroundColor = .background
        }
        
        setupHeader(in: view, title: Contentful.LocalStorage.communityQuestions?.title)
        
        Notifier.onCommunityQuestionsChanged.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    private func reload() {
        guard let communityQuestions = Contentful.LocalStorage.communityQuestions else { return }
        
        headerLabel.text = communityQuestions.title
        
        titleLabel.attributedText = communityQuestions.title.attributed.font(.header).color(.text)
        subtitleLabel.attributedText = communityQuestions.info.attributed.font(.subHeader).color(.text)
        
        questionViews.forEach { $0.removeFromSuperview() }
        questionViews = []
        
        for question in communityQuestions.questions {
            let questionView = QuestionView(question: question).add(toSuperview: containerView).customize {
                $0.pinLeading(to: containerView, plus: .padding).pinTrailing(to: containerView, plus: -.padding)

                if let last = questionViews.last {
                    $0.pinTop(to: last, .bottom, plus: .padding)
                }
                else {
                    $0.pinTop(to: subtitleLabel, .bottom, plus: .padding + 15)
                }
            }
            
            questionViews.append(questionView)
        }
        
        questionViews.last?.pinBottom(to: containerView, plus: -.padding)
    }
    
}

extension QuestionsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll()
    }
    
}
