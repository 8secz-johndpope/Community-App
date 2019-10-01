//
//  SearchPostsCell.swift
//  community
//
//  Created by Jonathan Landon on 8/10/18.
//

import UIKit
import Diakoneo

final class SearchPostsCell: CollectionViewCell {
    
    private var posts: [Contentful.Post] = []
    
    private let collectionView = UICollectionView(layout: LeftAlignedCollectionViewLayout(scrollDirection: .horizontal).customize {
        $0.minimumInteritemSpacing = .padding/2
        $0.minimumLineSpacing = .padding/2
        $0.sectionInset = UIEdgeInsets(left: .padding, right: .padding)
    })
    
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
    
    func configure(posts: [Contentful.Post]) {
        self.posts = posts
        self.collectionView.reloadData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posts = []
        collectionView.reloadData()
        collectionView.contentOffset = .zero
    }
    
    static func size(forPosts posts: [Contentful.Post], in collectionView: UICollectionView) -> CGSize {
        if posts.count == 1 {
            return CGSize(width: collectionView.width, height: .searchPostHeight)
        }
        else {
            return CGSize(width: collectionView.width, height: .searchPostHeight * 2 + .padding/2)
        }
    }
    
}

extension SearchPostsCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueCell(for: indexPath)
        cell.configure(post: posts[indexPath.row])
        return cell
    }
    
}

extension SearchPostsCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Cell.size(forPost: posts[indexPath.row], in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        posts.at(indexPath.row)?.show(from: .search)
    }
    
}

extension SearchPostsCell {
    
    final class Cell: CollectionViewCell {
        
        private let titleLabel = UILabel()
        private let dateLabel  = UILabel()
        
        override func setup() {
            super.setup()
            
            let shadowView = ContainerShadowView(superview: contentView).customize {
                $0.constrainEdgesToSuperview()
                $0.backgroundColor = .darkBlue
                $0.containerCornerRadius = 8
                $0.shadowOpacity = 0.2
            }
            
            let holderView = UIView(superview: contentView).customize {
                $0.pinLeading(to: shadowView, plus: .padding).pinTrailing(to: shadowView, plus: -.padding)
                $0.pinCenterY(to: shadowView)
            }
            
            titleLabel.add(toSuperview: holderView).customize {
                $0.pinLeading(to: holderView).pinTrailing(to: holderView)
                $0.pinTop(to: holderView).constrainSize(toFit: .horizontal, .vertical)
                $0.font = .bold(size: 16)
                $0.textColor = .white
                $0.numberOfLines = 2
            }
            
            dateLabel.add(toSuperview: holderView).customize {
                $0.pinLeading(to: holderView).pinTrailing(to: holderView)
                $0.pinTop(to: titleLabel, .bottom, plus: 5).pinBottom(to: holderView)
                $0.constrainSize(toFit: .vertical)
                $0.font = .regular(size: 14)
                $0.textColor = .white
            }
            
        }
        
        func configure(post: Contentful.Post) {
            titleLabel.text = post.title
            dateLabel.text = DateFormatter.readable.string(from: post.publishDate)
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            titleLabel.text = nil
            dateLabel.text = nil
        }
        
        static func size(forPost post: Contentful.Post, in collectionView: UICollectionView) -> CGSize {
            let titleWidth = post.title.size(boundingWidth: collectionView.width * 0.7, boundingHeight: 44, font: .bold(size: 16)).width.rounded(.up)
            let dateWidth = DateFormatter.readable.string(from: post.publishDate).size(boundingWidth: collectionView.width * 0.7, font: .regular(size: 14)).width.rounded(.up)
            
            let width = (.padding + max(titleWidth, dateWidth) + .padding).limited(200, collectionView.width * 0.7)
            
            return CGSize(width: width, height: .searchPostHeight)
        }
        
    }
    
}
