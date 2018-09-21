//
//  TableSectionView.swift
//  community
//
//  Created by Jonathan Landon on 8/6/18.
//

import UIKit
import Alexandria

final class TableSectionView: View {
    
    private var posts: [Contentful.Post] = []
    
    private let collectionView = UICollectionView(layout: .horizontal(lineSpacing: .padding, sectionInset: UIEdgeInsets(left: .padding, right: .padding)))
    
    override func setup() {
        super.setup()
        
        clipsToBounds = false
        
        collectionView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.constrainHeight(to: .tablePostHeight)
            $0.registerCell(TablePostCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.showsHorizontalScrollIndicator = false
            $0.alwaysBounceHorizontal = true
            $0.decelerationRate = UIScrollViewDecelerationRateFast
            $0.backgroundColor = .clear
            $0.clipsToBounds = false
        }
    }
    
    func configure(table: Contentful.Table?) {
        posts = table?.posts ?? []
        collectionView.reloadData()
    }
    
}

extension TableSectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TablePostCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(post: posts[indexPath.row])
        return cell
    }
    
}

extension TableSectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 220, height: .tablePostHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let post = posts.at(indexPath.row) else { return }
        switch post {
        case .external(let post): DeepLink.handle(url: post.url)
        case .text(let post):     TextPostViewController(textPost: post).show()
        }
    }
    
}
