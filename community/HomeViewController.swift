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
                guard let info = Contentful.LocalStorage.pantry?.info, !info.isEmpty else { return }
                UIAlertController.alert(message: info).addAction(title: "OK").present()
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
        
        containerView.configure(elements: [
            .view(.clear, 60),
            .custom(TableHeaderView()),
            .view(.clear, .padding),
            .custom(tableSectionView),
            .view(.clear, .padding),
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
        
        loadingIndicator.add(toSuperview: view).customize {
            $0.pinCenterX(to: view).pinSafely(.top, to: view, plus: 60 + 35 + .padding + .tablePostHeight/2 - 15)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.color = .white
            $0.startAnimating()
        }
        
        Notifier.onTableChanged.subscribePast(with: self) { [weak self] in
            self?.tableSectionView.configure(posts: Contentful.LocalStorage.tablePosts)
            self?.pantrySectionView.configure(shelves: Contentful.LocalStorage.pantry?.shelves ?? [])
            self?.loadingIndicator.stopAnimating()
            self?.refreshControl.endRefreshing()
        }.onQueue(.main)
        
        fetchContent()
    }
    
    @objc dynamic private func reload() {
        fetchContent()
    }
    
    private func fetchContent() {
        
        var entries: [Contentful.Entry] = []
        var assets: [Contentful.Asset] = []
        
        let processor = SimpleSerialProcessor()
        
        processor.enqueue { dequeue in
            Contentful.API.Content.fetchAll { result in
                print("All content: \(result.value?.count ?? -1)")
                entries = result.value ?? []
                dequeue()
            }
        }
        
        processor.enqueue { dequeue in
            Contentful.API.Asset.fetchAll { result in
                print("All assets: \(result.value?.count ?? -1)")
                assets = result.value ?? []
                dequeue()
            }
        }
        
        processor.enqueue { dequeue in
            
            var authors: [Contentful.Author] = []
            var externalPosts: [Contentful.ExternalPost] = []
            var textPosts: [Contentful.TextPost] = []
            var shelves: [Contentful.Shelf] = []
            var pantry: Contentful.Pantry?
            
            for entry in entries {
                switch entry {
                case .author(let author):             authors.append(author)
                case .externalPost(let externalPost): externalPosts.append(externalPost)
                case .pantry(let p):                  pantry = p
                case .textPost(let textPost):         textPosts.append(textPost)
                case .shelf(let shelf):               shelves.append(shelf)
                }
            }
            
            Contentful.LocalStorage.authors       = authors
            Contentful.LocalStorage.assets        = assets
            Contentful.LocalStorage.externalPosts = externalPosts
            Contentful.LocalStorage.textPosts     = textPosts
            Contentful.LocalStorage.shelves       = shelves
            Contentful.LocalStorage.pantry        = pantry
            
            Notifier.onTableChanged.fire(())
            
            dequeue()
        }
    }
    
}
