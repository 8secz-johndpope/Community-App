//
//  HomeViewController.swift
//  community
//
//  Created by Jonathan Landon on 8/6/18.
//

import UIKit
import Diakoneo

final class HomeViewController: ViewController {
    
    private let scrollView          = UIScrollView()
    private let containerView       = StackView(axis: .vertical)
    private let tableHeaderView     = TableHeaderView()
    private let tableSectionView    = TableSectionView()
    private let questionsView       = CommunityQuestionsView()
    private let loadingIndicator    = LoadingView()
    private let refreshControl      = UIRefreshControl()
    
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
            $0.backgroundColor = .headerBackground
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            
            if #available(iOS 11, *) {}
            else { $0.contentInset.bottom = 49 }
        }
        
        refreshControl.add(toSuperview: scrollView).customize {
            $0.addTarget(self, action: #selector(reload), for: .valueChanged)
            $0.tintColor = .background
        }
        
        containerView.add(toSuperview: scrollView).customize {
            $0.constrainEdgesToSuperview()
            $0.constrainWidth(to: scrollView)
            $0.backgroundColor = .clear
        }
        
        containerView.configure(elements: [
            .view(.clear, 44),
            .custom(tableHeaderView),
            .view(.clear, .padding),
            .custom(tableSectionView),
            .view(.clear, .padding),
            .view(.background, .padding),
            .custom(questionsView),
        ])
        
        UIView().add(toSuperview: containerView, at: 0).customize {
            $0.pinLeading(to: containerView).pinTrailing(to: containerView)
            $0.pinTop(to: containerView, .bottom).constrainHeight(to: view.height)
            $0.backgroundColor = .background
        }
        
        UIView(superview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinBottomToTopSafeArea(in: self)
            $0.backgroundColor = .headerBackground
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
        Content.loadAll { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
}
