//
//  PantryViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import Diakoneo

final class PantryViewController: ViewController {
    
    enum Cell {
        case space(CGFloat)
        case header(String, String)
        case shelf(Contentful.Shelf)
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case let .space(height):           return CGSize(width: collectionView.width, height: height)
            case let .header(title, subtitle): return HeaderCell.size(ofTitle: title, subtitle: subtitle, in: collectionView)
            case let .shelf(shelf):            return ShelfCell.size(ofShelf: shelf, in: collectionView)
            }
        }
    }
    
    private var cells: [Cell] = []
    
    private let collectionView = UICollectionView(layout: .vertical(lineSpacing: 0, sectionInset: UIEdgeInsets(bottom: .padding)))
    private let shadowView     = ShadowView()
    private let headerView     = UIView()
    private let headerLabel    = UILabel()
    private let refreshControl = UIRefreshControl()
    
    private var isShowingHeaderLabel = false
    
    override func viewDidAppearForFirstTime() {
        super.viewDidAppearForFirstTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.headerView.isHidden = false
        }
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
        
        generateCells()
        
        view.backgroundColor = .lightBackground
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(UICollectionViewCell.self)
            $0.registerCell(HeaderCell.self)
            $0.registerCell(ShelfCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.contentInset.top = 44
        }
        
        refreshControl.add(toSuperview: collectionView).customize {
            $0.addTarget(self, action: #selector(reloadContent), for: .valueChanged)
            $0.tintColor = .dark
        }
        
        headerView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinBottomToTopSafeArea(in: self, plus: 50)
            $0.backgroundColor = .lightBackground
            $0.alpha = 0
            $0.isHidden = true
        }
        
        shadowView.add(toSuperview: view, behind: headerView).customize {
            $0.pinLeading(to: headerView).pinTrailing(to: headerView)
            $0.pinTop(to: headerView).pinBottom(to: headerView)
            $0.backgroundColor = .lightBackground
            $0.shadowOpacity = 0.2
            $0.alpha = 0
        }
        
        headerLabel.add(toSuperview: headerView).customize {
            $0.pinBottom(to: headerView).constrainHeight(to: 50)
            $0.pinCenterX(to: headerView).constrainSize(toFit: .horizontal)
            $0.font = .bold(size: 16)
            $0.textColor = .dark
            $0.text = Contentful.LocalStorage.pantry?.title
        }
        
        Notifier.onPantryChanged.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
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
    
    private func reload() {
        headerLabel.text = Contentful.LocalStorage.pantry?.title
        generateCells()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    private func generateCells() {
        cells.removeAll()
        cells.append(.header(Contentful.LocalStorage.pantry?.title ?? "", Contentful.LocalStorage.pantry?.info ?? ""))
        cells.append(.space(.padding))
        cells.append(contentsOf: Contentful.LocalStorage.pantry?.shelves.map(Cell.shelf) ?? [])
    }
    
    private func infoTapped() {
        guard let info = Contentful.LocalStorage.pantry?.info else { return }
        UIAlertController.alert(message: info).addAction(title: "OK").present()
    }
    
    @objc dynamic private func reloadContent() {
        Contentful.API.loadAllContent()
    }
    
}

extension PantryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case .space:
            return collectionView.dequeueCell(for: indexPath)
        case let .header(title, subtitle):
            let cell: HeaderCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(title: title, subtitle: subtitle)
            return cell
        case .shelf(let shelf):
            let cell: ShelfCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(shelf: shelf)
            return cell
        }
    }
    
}

extension PantryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.alpha = scrollView.adjustedOffset.y.map(from: 40...60, to: 0...1).limited(0, 1)
        
        if scrollView.adjustedOffset.y > 40 {
            if !isShowingHeaderLabel {
                isShowingHeaderLabel = true
                UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                    self.headerView.alpha = 1
                }, completion: nil)
            }
        }
        else {
            if isShowingHeaderLabel {
                isShowingHeaderLabel = false
                UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                    self.headerView.alpha = 0
                }, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cells[indexPath.row].size(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .shelf(let shelf)? = cells.at(indexPath.row) else { return }
        navigationController?.pushViewController(ShelfViewController(shelf: shelf), animated: true)
        Analytics.viewed(shelf: shelf, source: .pantry)
    }
    
}
