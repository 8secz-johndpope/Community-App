//
//  HomeViewController.swift
//  community
//
//  Created by Jonathan Landon on 8/6/18.
//

import UIKit
import Alexandria

final class HomeViewController: ViewController {
    
    private let scrollView        = UIScrollView()
    private let containerView     = StackView(axis: .vertical)
    private let tableHeaderView   = TableHeaderView()
    private let tableSectionView  = TableSectionView()
    private let questionsView     = CommunityQuestionsView()
    private let loadingIndicator  = LoadingView()
    private let refreshControl    = UIRefreshControl()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Storage.has(.introVideoWasShown) {
            Notifier.onIntroChanged.subscribePastOnce(with: self) {
                VideoViewController().show(buttonMinY: .safeTop + 44)
                Storage.set(true, for: .introVideoWasShown)
            }.onQueue(.main)
        }
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
        
        scrollView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .darkBlue
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            
            if #available(iOS 11, *) {}
            else { $0.contentInset.bottom = 49 }
        }
        
        refreshControl.add(toSuperview: scrollView).customize {
            $0.addTarget(self, action: #selector(reload), for: .valueChanged)
            $0.tintColor = .lightBackground
        }
        
        containerView.add(toSuperview: scrollView).customize {
            $0.constrainEdgesToSuperview()
            $0.constrainWidth(to: scrollView)
            $0.backgroundColor = .clear
        }
        
        func header(text: NSAttributedString, backgroundColor: UIColor) -> UIView {
            let view = UIView().customize {
                $0.backgroundColor = backgroundColor
            }
            
            UILabel(superview: view).customize {
                $0.pinTop(to: view).pinBottom(to: view)
                $0.pinLeading(to: view, plus: .padding).constrainSize(toFit: .vertical, .horizontal)
                $0.attributedText = text
                $0.backgroundColor = backgroundColor
            }
            
            return view
        }
        
        func number(_ value: Int, text: String, backgroundColor: UIColor) -> UIView {
            let view = UIView().customize {
                $0.backgroundColor = backgroundColor
            }
            
            let number = UILabel(superview: view).customize {
                $0.pinTop(to: view).pinBottom(to: view, atPriority: .required - 1)
                $0.pinLeading(to: view, plus: .padding).constrainWidth(to: 30).constrainHeight(to: 30)
                $0.backgroundColor = .gold
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
                $0.textColor = .dark
                $0.numberOfLines = 0
            }
            
            return view
        }
        
        containerView.configure(elements: [
            .view(.clear, 44),
            .custom(tableHeaderView),
            .view(.clear, .padding),
            .custom(tableSectionView),
            .view(.clear, .padding),
            .view(.lightBackground, .padding),
            .custom(questionsView),
        ])
        
        UIView().add(toSuperview: containerView, at: 0).customize {
            $0.pinLeading(to: containerView).pinTrailing(to: containerView)
            $0.pinTop(to: containerView, .bottom).constrainHeight(to: view.height)
            $0.backgroundColor = .lightBackground
        }
        
        UIView(superview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinBottomToTopSafeArea(in: self)
            $0.backgroundColor = .darkBlue
        }
        
        loadingIndicator.add(toSuperview: view).customize {
            $0.pinCenterX(to: view).pinSafely(.top, to: view, plus: 60 + 35 + .padding + .tablePostHeight/2 - 15)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.color = .white
            $0.startAnimating()
        }
        
        Notifier.onTableChanged.subscribePast(with: self) { [weak self] in
            self?.tableSectionView.configure(table: Contentful.LocalStorage.table)
            self?.tableHeaderView.configure(table: Contentful.LocalStorage.table)
            self?.loadingIndicator.stopAnimating()
            self?.refreshControl.endRefreshing()
        }.onQueue(.main)
        
        Notifier.onCommunityQuestionsChanged.subscribePast(with: self) { [weak self] in
            guard let questions = Contentful.LocalStorage.communityQuestions else { return }
            self?.questionsView.configure(communityQuestions: questions)
        }.onQueue(.main)
    }
    
    @objc dynamic private func reload() {
        Contentful.API.loadAllContent()
    }
    
}
