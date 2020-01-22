//
//  PantryViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import Diakoneo

final class PantryViewController: ViewController, HeaderViewController, ReloadingViewController {
    
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
    
    let refreshControl = UIRefreshControl()
    
    var scrollView: UIScrollView { collectionView }
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
        
        navigationController?.isNavigationBarHidden = true
        
        generateCells()
        
        view.backgroundColor = .background
        
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
            $0.tintColor = .text
        }
        
        setupHeader(in: view, title: Contentful.LocalStorage.pantry?.title)
        
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
        didScroll()
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
