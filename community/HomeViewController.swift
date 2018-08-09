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
    private let tableSectionView  = TableSectionView()
    private let pantrySectionView = PantrySectionView()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
        
        scrollView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .grayBlue
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
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
        
        containerView.configure(elements: [
            .view(.grayBlue, 60),
            .custom(header(text: "The Table".attributed.font(.extraBold(size: 35)).color(.lightBackground), backgroundColor: .grayBlue)),
            .view(.grayBlue, .padding),
            .custom(tableSectionView),
            .view(.grayBlue, .padding),
            .view(.lightBackground, .padding),
            .custom(header(text: "More Resources".attributed.font(.extraBold(size: 20)).color(.dark), backgroundColor: .lightBackground)),
            .view(.lightBackground, .padding),
            .custom(pantrySectionView),
            .view(.lightBackground, .padding),
        ])
        
        UIView().add(toSuperview: containerView, at: 0).customize {
            $0.pinLeading(to: containerView).pinTrailing(to: containerView)
            $0.pinTop(to: containerView, .bottom).constrainHeight(to: view.height)
            $0.backgroundColor = .lightBackground
        }
        
        UIView(superview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top)
            $0.backgroundColor = .grayBlue
        }
        
        Notifier.onTableChanged.subscribePast(with: self) { [weak self] in
            self?.tableSectionView.configure(posts: Contentful.LocalStorage.tablePosts)
            self?.pantrySectionView.configure(shelves: Contentful.LocalStorage.pantry?.shelves ?? [])
        }.onQueue(.main)
    }
    
}
