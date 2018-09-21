//
//  HomeViewController.swift
//  community
//
//  Created by Jonathan Landon on 8/6/18.
//

import UIKit
import Alexandria

final class TableHeaderView: View {
    
    private let label = UILabel()
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
        
        label.add(toSuperview: self).customize {
            $0.pinTop(to: self).pinBottom(to: self)
            $0.pinLeading(to: self, plus: .padding).constrainSize(toFit: .vertical, .horizontal)
            $0.backgroundColor = .clear
            $0.attributedText = "The Table".attributed.font(.extraBold(size: 35)).color(.lightBackground)
        }
        
        UIButton().add(toSuperview: self).customize {
            $0.pinTop(to: self).pinBottom(to: self)
            $0.pinLeading(to: label, .trailing).constrainWidth(to: $0, .height)
            $0.setTitle(Icon.infoCircle.string, for: .normal)
            $0.setTitleColor(.lightBackground, for: .normal)
            $0.setTitleColor(.light, for: .highlighted)
            $0.adjustsImageWhenHighlighted = false
            $0.titleLabel?.font = .fontAwesome(.regular, size: 20)
            $0.contentVerticalAlignment = .bottom
            $0.contentEdgeInsets = UIEdgeInsets(bottom: 10)
            $0.addTarget(for: .touchUpInside) {
                guard let info = Contentful.LocalStorage.table?.info, !info.isEmpty else { return }
                UIAlertController.alert(message: info).addAction(title: "OK").present()
            }
        }
    }
    
}

final class CommunityQuestionsView: View {
    
    private let label = UILabel()
    
    override func setup() {
        super.setup()
        
        backgroundColor = .lightBackground
        
        label.add(toSuperview: self).customize {
            $0.pinTop(to: self).pinBottom(to: self)
            $0.pinLeading(to: self, plus: .padding).constrainSize(toFit: .vertical, .horizontal)
            $0.backgroundColor = .lightBackground
            $0.attributedText = "Community Questions".attributed.font(.extraBold(size: 20)).color(.dark)
        }
        
        UIButton().add(toSuperview: self).customize {
            $0.pinTop(to: self).pinBottom(to: self)
            $0.pinLeading(to: label, .trailing).pinTrailing(to: self, plus: -.padding)
            $0.constrainWidth(to: 40, .greaterThanOrEqual)
            $0.setTitle(Icon.infoCircle.string, for: .normal)
            $0.setTitleColor(.dark, for: .normal)
            $0.setTitleColor(.black, for: .highlighted)
            $0.adjustsImageWhenHighlighted = false
            $0.titleLabel?.font = .fontAwesome(.regular, size: 18)
            $0.contentVerticalAlignment = .bottom
            $0.contentHorizontalAlignment = .left
            $0.contentEdgeInsets = UIEdgeInsets(bottom: 4, left: 10)
            $0.addTarget(for: .touchUpInside) {
                guard let questionsPost = Contentful.LocalStorage.communityQuestions else { return }
                TextPostViewController(textPost: questionsPost).show()
            }
        }
    }
    
}


final class HomeViewController: ViewController {
    
    private let scrollView        = UIScrollView()
    private let containerView     = StackView(axis: .vertical)
    private let tableSectionView  = TableSectionView()
    private let pantrySectionView = PantrySectionView()
    private let loadingIndicator  = LoadingView()
    private let refreshControl    = UIRefreshControl()
    
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
                $0.backgroundColor = .orange
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
            .custom(TableHeaderView()),
            .view(.clear, .padding),
            .custom(tableSectionView),
            .view(.clear, .padding),
            .view(.lightBackground, .padding),
            .custom(CommunityQuestionsView()),
            .view(.lightBackground, .padding),
            .custom(number(1, text: "What has God taught you this week?", backgroundColor: .lightBackground)),
            .view(.lightBackground, .padding),
            .custom(number(2, text: "What thoughts or actions have hindered your walk with Christ this week?", backgroundColor: .lightBackground)),
            .view(.lightBackground, .padding),
            .custom(number(3, text: "How have you helped others see or know Jesus this week?", backgroundColor: .lightBackground)),
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
        
        loadingIndicator.add(toSuperview: view).customize {
            $0.pinCenterX(to: view).pinSafely(.top, to: view, plus: 60 + 35 + .padding + .tablePostHeight/2 - 15)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.color = .white
            $0.startAnimating()
        }
        
        Notifier.onTableChanged.subscribePast(with: self) { [weak self] in
            self?.tableSectionView.configure(table: Contentful.LocalStorage.table)
            self?.pantrySectionView.configure(shelves: Contentful.LocalStorage.pantry?.shelves ?? [])
            self?.loadingIndicator.stopAnimating()
            self?.refreshControl.endRefreshing()
        }.onQueue(.main)
    }
    
    @objc dynamic private func reload() {
        Contentful.API.loadAllContent()
    }
    
}
