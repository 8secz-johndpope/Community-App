//
//  ShelfViewController.swift
//  community
//
//  Created by Jonathan Landon on 8/4/18.
//

import UIKit
import Diakoneo

final class ShelfViewController: ViewController {
    
    enum Cell {
        case shelf(Contentful.Shelf)
        case post(Contentful.Post)
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case .shelf:          return CGSize(width: collectionView.width, height: 50)
            case .post(let post): return PantryPostCell.size(forPost: post, in: collectionView)
            }
        }
    }
    
    private let shelf: Contentful.Shelf
    private let cells: [Cell]
    
    private let collectionView = UICollectionView(layout: .vertical(lineSpacing: .padding, sectionInset: UIEdgeInsets(top: .padding, bottom: .padding)))
    
    private let shadowView = ShadowView()
    private let headerView = UIView()
    private let titleLabel = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10, trailingBuffer: 20)
    
    required init(shelf: Contentful.Shelf) {
        self.shelf = shelf
        self.cells = shelf.posts.map(Cell.post) + shelf.shelves.map(Cell.shelf)
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
        navigationController?.isNavigationBarHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .background
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(ShelfCell.self)
            $0.registerCell(PantryPostCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .background
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.contentInset.top = 60
            
            if navigationController == nil {
                $0.panGestureRecognizer.addTarget(self, action: #selector(userDidPan))
            }
        }
        
        headerView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinBottomToTopSafeArea(in: self, plus: 60)
            $0.backgroundColor = .clear
        }
        
        UIView(superview: headerView).customize {
            $0.pinLeading(to: headerView).pinTrailing(to: headerView)
            $0.pinBottom(to: headerView).constrainHeight(to: 1)
            $0.backgroundColor = .tabBarLine
        }
        
        shadowView.add(toSuperview: view, behind: headerView).customize {
            $0.pinLeading(to: headerView).pinTrailing(to: headerView)
            $0.pinTop(to: headerView).pinBottom(to: headerView)
            $0.backgroundColor = .background
            $0.shadowOpacity = 0.2
            $0.alpha = 0
        }
        
        UIButton().add(toSuperview: headerView).customize {
            $0.pinBottom(to: headerView).pinLeading(to: headerView)
            $0.constrainWidth(to: 60).constrainHeight(to: 60)
            $0.titleLabel?.font = .fontAwesome(.regular, size: 18)
            $0.setTitle(navigationController == nil ? Icon.times.string : Icon.chevronLeft.string, for: .normal)
            $0.setTitleColor(.text, for: .normal)
            $0.addTarget(for: .touchUpInside) { [weak self] in
                if let navigationController = self?.navigationController {
                    navigationController.popViewController(animated: true)
                }
                else {
                    self?.dismiss(animated: true)
                }
            }
        }
        
        titleLabel.add(toSuperview: headerView).customize {
            $0.pinBottom(to: headerView).constrainHeight(to: 60)
            $0.pinLeading(to: headerView, plus: 60).pinTrailing(to: headerView, plus: -60)
            $0.font = .bold(size: 16)
            $0.textColor = .text
            $0.textAlignment = .center
            $0.text = shelf.name
        }
    }
    
}

extension ShelfViewController: UICollectionViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.alpha = scrollView.adjustedOffset.y.map(from: 0...20, to: 0...1).limited(0, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case .shelf(let shelf):
            let cell: ShelfCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(shelf: shelf)
            return cell
        case .post(let post):
            let cell: PantryPostCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(post: post)
            return cell
        }
    }
    
}

extension ShelfViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cells[indexPath.row].size(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = cells.at(indexPath.row) else { return }
        
        switch cell {
        case .shelf(let shelf):
            navigationController?.pushViewController(ShelfViewController(shelf: shelf), animated: true)
            Analytics.viewed(shelf: shelf, source: .pantry)
        case .post(let post):
            post.show(in: self, from: .pantry)
        }
    }
    
}
