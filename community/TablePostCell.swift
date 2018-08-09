//
//  TablePostCell.swift
//  community
//
//  Created by Jonathan Landon on 8/2/18.
//

import UIKit
import Alexandria


final class TablePostCell: CollectionViewCell {
    
    private let shadowView = ContainerShadowView()
    private let imageView  = LoadingImageView()
    private let titleLabel = UILabel()
    private let dateLabel  = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        shadowView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .lightBackground
            $0.containerCornerRadius = 8
            $0.shadowOpacity = 0.1
        }
        
        imageView.add(toSuperview: shadowView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.showDimmer = true
        }
        
        dateLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
            $0.pinBottom(to: contentView, plus: -.padding).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 14)
            $0.textAlignment = .left
            $0.textColor = .lightBackground
        }
        
        titleLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
            $0.pinBottom(to: dateLabel, .top, plus: -.padding/2).constrainSize(toFit: .vertical)
            $0.font = .semiBold(size: 16)
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.textColor = .lightBackground
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
        let cellWidth = collectionView.width - .padding * 2
        let labelWidth = cellWidth - .padding * 2
        
        let titleHeight = post.title.size(boundingWidth: labelWidth, font: .bold(size: 20)).height
        let dateHeight = DateFormatter.readable.string(from: post.publishDate).size(boundingWidth: labelWidth, font: .regular(size: 15)).height
        
        return CGSize(
            width: cellWidth,
            height: .padding + titleHeight + 10 + dateHeight + .padding
        )
    }
    
}
