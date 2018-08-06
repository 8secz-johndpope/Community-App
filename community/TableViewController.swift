//
//  HomeViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

final class TableViewController: ViewController {
    
    enum Cell {
        case header(String)
        case post(Contentful.Post)
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case .header:         return CGSize(width: collectionView.width - .padding * 2, height: 25)
            case .post(let post): return TablePostCell.size(forPost: post, in: collectionView)
            }
        }
    }
    
    private var cells: [Cell] = []
    
    private let collectionView = UICollectionView(layout: .vertical(itemSpacing: .padding, lineSpacing: .padding * 1.5, sectionInset: UIEdgeInsets(inset: .padding)))
    private let shadowView     = ShadowView()
    private let headerView     = UIView()
    private let tableLabel     = UILabel()
    
    override func setup() {
        super.setup()
        
        generateCells()
        
        view.backgroundColor = .lightBackground
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(HeaderCell.self)
            $0.registerCell(TablePostCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.contentInset.top = 60
        }
        
        headerView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top, plus: 60)
            $0.backgroundColor = .clear
        }
        
        shadowView.add(toSuperview: view, behind: headerView).customize {
            $0.pinLeading(to: headerView).pinTrailing(to: headerView)
            $0.pinTop(to: headerView).pinBottom(to: headerView)
            $0.backgroundColor = .white
            $0.shadowOpacity = 0.2
            $0.alpha = 0
        }
        
        UIButton().add(toSuperview: headerView).customize {
            $0.pinBottom(to: headerView).pinTrailing(to: headerView)
            $0.constrainWidth(to: 60).constrainHeight(to: 60)
            $0.titleLabel?.font = .fontAwesome(.regular, size: 20)
            $0.setTitle(Icon.infoCircle.string, for: .normal)
            $0.setTitleColor(.grayBlue, for: .normal)
            $0.addTarget(for: .touchUpInside) {
                guard let info = Contentful.LocalStorage.pantry?.info else { return }
                UIAlertController.alert(message: info).addAction(title: "OK").present()
            }
        }
        
        tableLabel.add(toSuperview: headerView).customize {
            $0.pinBottom(to: headerView).constrainHeight(to: 60)
            $0.pinCenterX(to: headerView).constrainSize(toFit: .horizontal)
            $0.font = .bold(size: 25)
            $0.textColor = .grayBlue
            $0.text = "The Table"
        }
        
        Notifier.onTableChanged.subscribePast(with: self) { [weak self] in
            self?.generateCells()
            self?.collectionView.reloadData()
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
    
    private func generateCells() {
        cells.removeAll()
        cells.append(contentsOf: Contentful.LocalStorage.tablePosts.map(Cell.post))
    }
    
}

extension TableViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case .header(let text):
            let cell: HeaderCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(text: text)
            return cell
        case .post(let post):
            let cell: TablePostCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(post: post)
            return cell
        }
    }
    
}

extension TableViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.alpha = scrollView.adjustedOffset.y.map(from: 0...20, to: 0...1).limited(0, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cells[indexPath.row].size(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .post(let post)? = cells.at(indexPath.row) else { return }
        
        switch post {
        case .external(let post): DeepLink.handle(url: post.url)
        case .text(let post):     TextPostViewController(textPost: post).show(in: self)
        }
    }
    
}

final class HeaderCell: CollectionViewCell {
    
    private let label = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        label.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.textColor = .dark
            $0.font = .extraBold(size: 20)
        }
    }
    
    func configure(text: String) {
        label.text = text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
}
