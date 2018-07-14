//
//  PantryViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import Alexandria

final class PantryViewController: ViewController {
    
    private var shelves: [Contentful.Shelf] = []
    
    private let collectionView = UICollectionView(layout: .vertical(lineSpacing: 0))
    
    override func setup() {
        super.setup()
        
        shelves = Contentful.LocalStorage.pantry?.shelves ?? []
        
        view.backgroundColor = .white
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(ShelfCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .white
            $0.showsVerticalScrollIndicator = false
        }
        
        Notifier.onPantryChanged.subscribePast(with: self) { [weak self] in
            self?.shelves = Contentful.LocalStorage.pantry?.shelves ?? []
            self?.collectionView.reloadData()
        }.onQueue(.main)
    }
    
}

extension PantryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelves.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShelfCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(shelf: shelves[indexPath.row])
        return cell
    }
    
}

extension PantryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width, height: 215)
    }
    
}

final class ShelfCell: CollectionViewCell {
    
    private var posts: [Contentful.Post] = []
    
    private let gradientView   = GradientView(gradient: .shelf, direction: .vertical)
    private let titleLabel     = UILabel()
    private let collectionView = UICollectionView(layout: CarouselFlowLayout.shelfContent)
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = true
        
        gradientView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
        }
        
        titleLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
            $0.pinTop(to: contentView, plus: .padding).constrainSize(toFit: .vertical)
            $0.font = .extraBold(size: 20)
            $0.textColor = .dark
        }
        
        collectionView.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView).pinTrailing(to: contentView)
            $0.pinBottom(to: contentView).constrainHeight(to: .shelfCellHeight)
            $0.registerCell(Cell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.decelerationRate = UIScrollViewDecelerationRateFast
            $0.clipsToBounds = false
        }
        
        ShadowView(superview: contentView).customize {
            $0.pinLeading(to: contentView).pinTrailing(to: contentView)
            $0.pinTop(to: contentView, .bottom).constrainHeight(to: 100)
        }
    }
    
    func configure(shelf: Contentful.Shelf) {
        posts = shelf.posts
        
        titleLabel.text = shelf.name
        collectionView.reloadData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posts = []
        titleLabel.text = nil
        collectionView.reloadData()
    }
    
}

extension ShelfCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueCell(for: indexPath)
        cell.configure(post: posts[indexPath.row])
        return cell
    }
    
}

extension ShelfCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
}

extension ShelfCell {
    
    final class Cell: CollectionViewCell {
        
        private let shadowView = ShadowView()
        private let titleLabel = UILabel()
        
        override func setup() {
            super.setup()
            
            shadowView.add(toSuperview: contentView).customize {
                $0.constrainEdgesToSuperview()
                $0.backgroundColor = .white
            }
            
            titleLabel.add(toSuperview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
                $0.pinCenterY(to: contentView).constrainSize(toFit: .vertical)
                $0.font = .bold(size: 18)
                $0.textAlignment = .center
                $0.textColor = .dark
                $0.numberOfLines = 0
            }
            
        }
        
        func configure(post: Contentful.Post) {
            titleLabel.text = post.title
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            titleLabel.text = nil
        }
        
    }
    
}
