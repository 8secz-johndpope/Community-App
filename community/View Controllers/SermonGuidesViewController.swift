//
//  SermonGuidesViewController.swift
//  community
//
//  Created by Jonathan Landon on 1/20/20.
//

import UIKit
import Diakoneo

final class SermonGuidesViewController: ViewController, HeaderViewController, ReloadingViewController {
    
    enum Cell {
        case header(String, String)
        case guide(Contentful.Post)
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case let .header(title, subtitle): return HeaderCell.size(ofTitle: title, subtitle: subtitle, in: collectionView)
            case .guide:                       return CGSize(width: collectionView.width - .padding * 2, height: collectionView.width - .padding * 2)
            }
        }
    }
    
    private var cells: [Cell] = []
    
    var scrollView: UIScrollView { collectionView }
    let shadowView  = ShadowView()
    let headerView  = UIView()
    let headerLabel = UILabel()
    let refreshControl = UIRefreshControl()
    
    var isShowingHeaderLabel = false
    
    private let collectionView = UICollectionView(layout: .vertical(lineSpacing: .padding, sectionInset: UIEdgeInsets(bottom: .padding)))
    private let loadingIndicator = LoadingView()
    
    override func viewDidAppearForFirstTime() {
        super.viewDidAppearForFirstTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.headerView.isHidden = false
        }
    }
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .background
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(HeaderCell.self)
            $0.registerCell(SermonGuideCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.contentInset.top = 44
        }
        
        loadingIndicator.add(toSuperview: view).customize {
            $0.pinCenterX(to: view).pinCenterY(to: view)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.color = .text
            $0.startAnimating()
        }
        
        refreshControl.add(toSuperview: collectionView).customize {
            $0.addTarget(self, action: #selector(reloadContent), for: .valueChanged)
            $0.tintColor = .text
        }
        
        setupHeader(in: view, title: Contentful.LocalStorage.table?.title)
        
        Notifier.onTableChanged.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    private func reload() {
        headerLabel.text = Contentful.LocalStorage.table?.title
        
        cells.removeAll()
        cells.append(.header(Contentful.LocalStorage.table?.title ?? "", Contentful.LocalStorage.table?.info ?? ""))
        cells.append(contentsOf: Contentful.LocalStorage.table?.posts.map(Cell.guide) ?? [])
        
        loadingIndicator.stopAnimating()
        collectionView.reloadData()
    }
    
}

extension SermonGuidesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case let .header(title, subtitle):
            let cell: HeaderCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(title: title, subtitle: subtitle)
            return cell
        case let .guide(guide):
            let cell: SermonGuideCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(guide: guide)
            return cell
        }
    }
    
}

extension SermonGuidesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cells[indexPath.row].size(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .guide(let guide) = cells.at(indexPath.row) else { return }
        guide.show(from: .table)
    }
    
}
