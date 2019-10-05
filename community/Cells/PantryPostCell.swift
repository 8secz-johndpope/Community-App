//
//  PantryPostCell.swift
//  community
//
//  Created by Jonathan Landon on 8/9/18.
//

import UIKit
import Diakoneo

final class PantryPostCell: CollectionViewCell {
    
    private let shadowView = ContainerShadowView()
    private let imageView  = LoadingImageView()
    private let titleLabel = UILabel()
    private let dateLabel  = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        shadowView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .headerBackground
            $0.containerCornerRadius = 8
            $0.shadowOpacity = 0.2
        }
        
        imageView.add(toSuperview: shadowView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.contentMode = .scaleAspectFill
            $0.showDimmer = false
            $0.defaultGradient = .empty
            $0.backgroundColor = .backgroundAlt
        }
        
        UIView(superview: shadowView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .postOverlay
        }
        
        titleLabel.add(toSuperview: shadowView.container).customize {
            $0.pinLeading(to: shadowView.container, plus: .padding).pinTrailing(to: shadowView.container, plus: -.padding)
            $0.pinTop(to: shadowView.container, plus: .padding).constrainSize(toFit: .vertical)
            $0.font = .bold(size: 20)
            $0.textColor = .headerText
            $0.numberOfLines = 0
        }
        
        dateLabel.add(toSuperview: shadowView.container).customize {
            $0.pinLeading(to: shadowView.container, plus: .padding).pinTrailing(to: shadowView.container, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom, plus: 10).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 16)
            $0.textColor = .headerText
        }
    }
    
    func configure(post: Contentful.Post) {
        imageView.image = post.type.image
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
        
        let titleHeight = post.title.size(boundingWidth: labelWidth, font: .bold(size: 20)).height.rounded(.up)
        let dateHeight = DateFormatter.readable.string(from: post.publishDate).size(boundingWidth: labelWidth, font: .regular(size: 16)).height.rounded(.up)
        
        return CGSize(
            width: cellWidth,
            height: .padding + titleHeight + 10 + dateHeight + .padding
        )
    }
    
}
