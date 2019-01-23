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
    private let infoView   = UIView()
    private let typeLabel  = PaddedLabel(padding: UIEdgeInsets(left: 10, right: 10))
    private let titleLabel = UILabel()
    private let dateLabel  = UILabel()
    private let lineView   = UIView()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        shadowView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .dark
            $0.containerCornerRadius = 8
            $0.shadowOpacity = 0.4
            $0.shadowRadius = 10
        }
        
        imageView.add(toSuperview: shadowView.container).customize {
            $0.pinLeading(to: shadowView.container).pinTrailing(to: shadowView.container)
            $0.pinTop(to: shadowView.container).pinBottom(to: shadowView.container)
//            $0.pinTop(to: shadowView.container).constrainHeight(to: $0, .width, times: 9/16)
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.showDimmer = true
        }
        
//        dateLabel.add(toSuperview: shadowView.container).customize {
//            $0.pinLeading(to: shadowView.container, plus: .padding).pinTrailing(to: shadowView.container, plus: -.padding)
//            $0.pinBottom(to: shadowView.container, plus: -.padding).constrainSize(toFit: .vertical)
//            $0.font = .regular(size: 14)
//            $0.textColor = .white
//            $0.textAlignment = .left
//            $0.numberOfLines = 0
//        }
        
        titleLabel.add(toSuperview: shadowView.container).customize {
            $0.pinLeading(to: shadowView.container, plus: .padding).pinTrailing(to: shadowView.container, plus: -.padding)
            $0.pinBottom(to: shadowView.container, plus: -.padding).constrainSize(toFit: .vertical)
            $0.font = .title
            $0.textColor = .white
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
//        infoView.add(toSuperview: shadowView.container).customize {
//            $0.pinLeading(to: shadowView.container).pinTrailing(to: shadowView.container)
//            $0.pinBottom(to: shadowView.container)
//            $0.backgroundColor = .lightBackground
//        }
//
//        lineView.add(toSuperview: infoView).customize {
//            $0.pinLeading(to: infoView).pinTrailing(to: infoView)
//            $0.pinTop(to: infoView).constrainHeight(to: 1)
//            $0.backgroundColor = .lightest
//        }
//
//        let holderView = UIView(superview: infoView).customize {
//            $0.pinLeading(to: infoView, plus: .padding).pinTrailing(to: infoView, plus: -.padding)
//            $0.pinBottom(to: infoView, plus: -.padding * 0.75).pinTop(to: infoView, plus: .padding * 0.75)
//            $0.backgroundColor = .lightBackground
//        }
//
//        titleLabel.add(toSuperview: holderView).customize {
//            $0.pinLeading(to: holderView).pinTrailing(to: holderView)
//            $0.pinTop(to: holderView).constrainSize(toFit: .vertical)
//            $0.font = .bold(size: 16)
//            $0.textColor = .dark
//            $0.textAlignment = .left
//            $0.numberOfLines = 0
//        }
//
//        dateLabel.add(toSuperview: holderView).customize {
//            $0.pinLeading(to: holderView).pinTrailing(to: holderView)
//            $0.pinTop(to: titleLabel, .bottom, plus: 5).pinBottom(to: holderView)
//            $0.constrainSize(toFit: .vertical)
//            $0.font = .regular(size: 12)
//            $0.textColor = .dark
//            $0.textAlignment = .left
//            $0.numberOfLines = 0
//        }
        
//        typeLabel.add(toSuperview: shadowView.container).customize {
//            $0.pinLeading(to: shadowView.container).pinTop(to: shadowView.container)
//            $0.constrainHeight(to: 24).constrainSize(toFit: .horizontal)
//            $0.font = .regular(size: 10)
//            $0.textColor = .lightBackground
//            $0.cornerRadius = 12
//        }
    }
    
    func configure(post: Contentful.Post) {
        titleLabel.text = post.title
        dateLabel.text = DateFormatter.readable.string(from: post.publishDate)
        
        typeLabel.backgroundColor = post.type.backgroundColor
        typeLabel.text = post.type.title
        
        if let image = post.image {
            imageView.load(url: image)
            imageView.showDimmer = true
//            lineView.isHidden = false
        }
        else {
            shadowView.backgroundColor = post.type.backgroundColor
            imageView.image = post.type.image
            imageView.showDimmer = false
//            lineView.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.cancel()
        imageView.isHidden = false
        typeLabel.backgroundColor = .grayBlue
        typeLabel.text = nil
        titleLabel.text = nil
        dateLabel.text = nil
        shadowView.backgroundColor = .dark
    }
    
    static func size(forPost post: Contentful.Post, in collectionView: UICollectionView) -> CGSize {
        let cellWidth = collectionView.width - .padding * 2
        let labelWidth = cellWidth - .padding
        
        let titleHeight = post.title.size(boundingWidth: labelWidth, font: .bold(size: 16)).height
        let dateHeight = DateFormatter.readable.string(from: post.publishDate).size(boundingWidth: labelWidth, font: .regular(size: 12)).height
        
//        print("Title: \(post.title), \(titleHeight)")
//
//        if post.image != nil {
//            return CGSize(
//                width: cellWidth,
//                height: .padding/2 + 24 + titleHeight + 5 + dateHeight + .padding * 1.5
//            )
//        }
//        else {
            return CGSize(
                width: cellWidth,
                height: cellWidth * 9/16 + titleHeight + 5 + dateHeight + .padding * 1.5
            )
//        }
    }
    
}
