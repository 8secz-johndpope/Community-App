//
//  TableSectionView.swift
//  community
//
//  Created by Jonathan Landon on 8/6/18.
//

import UIKit
import Diakoneo

final class TableSectionView: View {
    
    private var posts: [Contentful.Post] = []
    
    private var shouldAnimateCells = true
    
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
            $0.decelerationRate = .fast
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard shouldAnimateCells else { return }
        
        if indexPath.row >= 1 {
            shouldAnimateCells = false
        }
        
        cell.transform = .translate(UIScreen.main.width, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0.25 + indexPath.row.double * 0.05, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: [], animations: {
            cell.transform = .identity
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        posts.at(indexPath.row)?.show(from: .table)
    }
    
}
