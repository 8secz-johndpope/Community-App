//
//  HomeViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

final class TableViewController: ViewController {
    
    enum Cell {
        case header(String, () -> Void)
        case post(Contentful.Post)
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case .header(let text, _): return HeaderCell.size(ofText: text, in: collectionView)
            case .post(let post):      return TablePostCell.size(forPost: post, in: collectionView)
            }
        }
    }
    
    private var cells: [Cell] = []
    
    private let collectionView = UICollectionView(layout: .vertical(lineSpacing: .padding * 1.5, sectionInset: UIEdgeInsets(bottom: .padding)))
    private let shadowView     = ShadowView()
    private let headerView     = UIView()
    private let headerLabel    = UILabel()
    
    private var isShowingHeaderLabel = false
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
        
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
            $0.contentInset.top = 44
        }
        
        headerView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top, plus: 50)
            $0.backgroundColor = .lightBackground
            $0.alpha = 0
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
        cells.append(.header("The Table", { [weak self] in self?.infoTapped() }))
        cells.append(contentsOf: Contentful.LocalStorage.table?.posts.map(Cell.post) ?? [])
    }
    
    private func infoTapped() {
        guard let info = Contentful.LocalStorage.table?.info else { return }
        UIAlertController.alert(message: info).addAction(title: "OK").present()
    }
    
}

extension TableViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case let .header(text, callback):
            let cell: HeaderCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(text: text, callback: callback)
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
        guard case .post(let post)? = cells.at(indexPath.row) else { return }
        
        switch post {
        case .external(let post): DeepLink.handle(url: post.url)
        case .text(let post):     TextPostViewController(textPost: post).show(in: self)
        }
    }
    
}

final class HeaderCell: CollectionViewCell {
    
    private var callback: () -> Void = {}
    
    private let label = UILabel()
    private let button = UIButton()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        label.add(toSuperview: contentView).customize {
            $0.pinTop(to: contentView).pinBottom(to: contentView)
            $0.pinLeading(to: contentView).constrainSize(toFit: .horizontal)
            $0.textColor = .dark
            $0.font = .extraBold(size: 35)
        }
        
        button.add(toSuperview: contentView).customize {
            $0.pinTop(to: contentView).pinBottom(to: contentView)
            $0.pinLeading(to: label, .trailing).constrainWidth(to: $0, .height)
            $0.setTitle(Icon.infoCircle.string, for: .normal)
            $0.setTitleColor(.dark, for: .normal)
            $0.setTitleColor(.black, for: .highlighted)
            $0.adjustsImageWhenHighlighted = false
            $0.titleLabel?.font = .fontAwesome(.regular, size: 20)
            $0.contentVerticalAlignment = .bottom
            $0.contentEdgeInsets = UIEdgeInsets(bottom: 10)
            $0.addTarget(for: .touchUpInside) { [weak self] in self?.callback() }
        }
    }
    
    func configure(text: String, callback: @escaping () -> Void) {
        self.label.text = text
        self.callback = callback
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        callback = {}
    }
    
    static func size(ofText text: String, in collectionView: UICollectionView) -> CGSize {
        let height = text.size(boundingWidth: .greatestFiniteMagnitude, font: .extraBold(size: 35)).height
        
        return CGSize(
            width: collectionView.width - .padding * 2,
            height: height
        )
    }
    
}
