//
//  SearchShelvesCell.swift
//  community
//
//  Created by Jonathan Landon on 8/10/18.
//

import UIKit

final class SearchShelvesCell: CollectionViewCell {
    
    private var shelves: [Contentful.Shelf] = []
    
    private let collectionView = UICollectionView(layout: .horizontal(itemSpacing: .padding/2, lineSpacing: .padding, sectionInset: UIEdgeInsets(left: .padding, right: .padding)))
    
    override func setup() {
        super.setup()
        
        backgroundColor = .lightBackground
        
        collectionView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(Cell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .lightBackground
            $0.showsHorizontalScrollIndicator = false
            $0.decelerationRate = .fast
            $0.alwaysBounceHorizontal = true
            $0.clipsToBounds = false
        }
    }
    
    func configure(shelves: [Contentful.Shelf]) {
        self.shelves = shelves
        self.collectionView.reloadData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        shelves = []
        collectionView.reloadData()
        collectionView.contentOffset = .zero
    }
    
    static func size(in collectionView: UICollectionView) -> CGSize {
        return CGSize(width: collectionView.width, height: .searchShelfHeight)
    }
    
}

extension SearchShelvesCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelves.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueCell(for: indexPath)
        cell.configure(shelf: shelves[indexPath.row])
        return cell
    }
    
}

extension SearchShelvesCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Cell.size(forShelf: shelves[indexPath.row], in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let shelf = self.shelves.at(indexPath.row) else { return }
        UIViewController.current?.navigationController?.pushViewController(ShelfViewController(shelf: shelf), animated: true)
    }
    
}

extension SearchShelvesCell {
    
    final class Cell: CollectionViewCell {
        
        private let iconView   = UILabel()
        private let titleLabel = UILabel()
        
        override func setup() {
            super.setup()
            
            let shadowView = ContainerShadowView(superview: contentView).customize {
                $0.constrainEdgesToSuperview()
                $0.backgroundColor = .lightBackground
                $0.containerCornerRadius = 8
                $0.shadowOpacity = 0.1
            }
            
            iconView.add(toSuperview: shadowView.container).customize {
                $0.pinCenterX(to: shadowView.container, .leading, plus: .padding * 1.5).pinCenterY(to: shadowView.container)
                $0.constrainSize(toFit: .vertical, .horizontal)
                $0.font = .fontAwesome(.solid, size: 20)
                $0.textColor = .dark
                $0.isHidden = true
            }
            
            titleLabel.add(toSuperview: shadowView.container).customize {
                $0.pinLeading(to: shadowView.container, plus: .padding).pinTrailing(to: shadowView.container, plus: -.padding)
                $0.pinCenterY(to: shadowView.container).constrainSize(toFit: .vertical)
                $0.font = .regular(size: 16)
                $0.textColor = .dark
                $0.numberOfLines = 2
            }
            
        }
        
        func configure(shelf: Contentful.Shelf) {
            shelf.icon.flatMap(iconView.set(icon:))
            titleLabel.text = shelf.name
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            iconView.text = nil
            titleLabel.text = nil
        }
        
        static func size(forShelf shelf: Contentful.Shelf, in collectionView: UICollectionView) -> CGSize {
            let nameWidth = shelf.name.size(font: .regular(size: 16)).width.rounded(.up)
            let width = (.padding + nameWidth + .padding).limited(50, collectionView.width * 0.9)
            
            return CGSize(width: width, height: collectionView.height)
        }
        
    }
    
}
