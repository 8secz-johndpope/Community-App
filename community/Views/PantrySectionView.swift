//
//  PantrySectionCell.swift
//  community
//
//  Created by Jonathan Landon on 8/6/18.
//

import UIKit
import Diakoneo

final class PantrySectionView: View {
    
    private var shelves: [Contentful.Shelf] = []
    
    private let collectionView = SelfSizingCollectionView(layout: .vertical(lineSpacing: 0))
    
    override func setup() {
        super.setup()
        
        collectionView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(ShelfCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .background
        }
    }
    
    func configure(shelves: [Contentful.Shelf]) {
        self.shelves = Array(shelves.prefix(5))
        self.collectionView.reloadData()
    }
    
}

extension PantrySectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelves.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShelfCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(shelf: shelves[indexPath.row])
        return cell
    }
    
}

extension PantrySectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let shelf = shelves.at(indexPath.row) else { return }
        UIViewController.current?.navigationController?.pushViewController(ShelfViewController(shelf: shelf), animated: true)
    }
    
}
