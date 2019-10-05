//
//  TablePostCell.swift
//  community
//
//  Created by Jonathan Landon on 8/2/18.
//

import UIKit
import Diakoneo

final class TablePostCell: CollectionViewCell {
    
    private let shadowView = ContainerShadowView()
    private let imageView  = LoadingImageView()
    private let titleLabel = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        shadowView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .text
            $0.containerCornerRadius = 8
            $0.shadowOpacity = 0.4
            $0.shadowRadius = 10
        }
        
        imageView.add(toSuperview: shadowView.container).customize {
            $0.pinLeading(to: shadowView.container).pinTrailing(to: shadowView.container)
            $0.pinTop(to: shadowView.container).pinBottom(to: shadowView.container)
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.showDimmer = true
            $0.defaultGradient = .empty
            $0.backgroundColor = .backgroundAlt
        }
        
        titleLabel.add(toSuperview: shadowView.container).customize {
            $0.pinLeading(to: shadowView.container, plus: .padding).pinTrailing(to: shadowView.container, plus: -.padding)
            $0.pinBottom(to: shadowView.container, plus: -.padding).constrainSize(toFit: .vertical)
            $0.font = .title
            $0.textColor = .white
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
    }
    
    func configure(post: Contentful.Post) {
        titleLabel.text = post.title
        
        if let image = post.image {
            imageView.load(url: image)
            imageView.showDimmer = true
        }
        else {
            imageView.image = post.type.image
            imageView.showDimmer = false
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.cancel()
        imageView.isHidden = false
        titleLabel.text = nil
        shadowView.backgroundColor = .text
    }
    
    static func size(forPost post: Contentful.Post, in collectionView: UICollectionView) -> CGSize {
        let cellWidth = collectionView.width - .padding * 2
        let labelWidth = cellWidth - .padding
        
        let titleHeight = post.title.size(boundingWidth: labelWidth, font: .bold(size: 16)).height
        let dateHeight = DateFormatter.readable.string(from: post.publishDate).size(boundingWidth: labelWidth, font: .regular(size: 12)).height
        
        return CGSize(
            width: cellWidth,
            height: cellWidth * 9/16 + titleHeight + 5 + dateHeight + .padding * 1.5
        )
    }
    
}
