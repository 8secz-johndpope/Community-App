//
//  TablePostCell.swift
//  community
//
//  Created by Jonathan Landon on 8/2/18.
//

import UIKit
import Alexandria


final class TablePostCell: CollectionViewCell {
    
    private let containerView = ContainerShadowView()
    private let titleLabel    = UILabel()
    private let dateLabel     = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        containerView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .grayBlue
            $0.containerCornerRadius = 4
        }
        
        titleLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinTop(to: containerView.container, plus: .padding).constrainSize(toFit: .vertical)
            $0.font = .bold(size: 20)
            $0.textAlignment = .left
            $0.numberOfLines = 3
            $0.textColor = .lightBackground
        }
        
        dateLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom, plus: 10).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 15)
            $0.textAlignment = .left
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
