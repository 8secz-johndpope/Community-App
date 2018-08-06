//
//  SeriesMessageCell.swift
//  community
//
//  Created by Jonathan Landon on 7/31/18.
//

import UIKit
import Alexandria

final class SeriesMessageCell: CollectionViewCell {
    
    private let containerView    = ContainerShadowView()
    private let titleLabel       = UILabel()
    private let speakerImageView = LoadingImageView()
    private let speakerLabel     = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        containerView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .lightBackground
            $0.containerCornerRadius = 4
        }
        
        titleLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinTop(to: containerView.container, plus: .padding).constrainSize(toFit: .vertical)
            $0.font = .bold(size: 16)
            $0.textColor = .dark
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
        speakerImageView.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTop(to: titleLabel, .bottom, plus: 10)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.cornerRadius = 15
            $0.contentMode = .scaleAspectFill
        }
        
        speakerLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: speakerImageView, .trailing, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinCenterY(to: speakerImageView).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 12)
            $0.textColor = .dark
            $0.numberOfLines = 1
        }
    }
    
    func configure(message: Watermark.Message) {
        titleLabel.text = message.title
        speakerLabel.text = message.speakers.map { $0.name }.joined(separator: ", ")
        
        speakerImageView.load(url: message.speakers.first?.image)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        speakerLabel.text = nil
        
        speakerImageView.cancel()
    }
    
    static func size(forMessage message: Watermark.Message, in collectionView: UICollectionView) -> CGSize {
        let cellWidth = collectionView.width - .padding * 2
        let labelWidth = cellWidth - .padding * 2
        
        let titleHeight = message.title.size(boundingWidth: labelWidth, font: .bold(size: 16)).height
        
        return CGSize(
            width: cellWidth,
            height: .padding + titleHeight + 10 + 30 + .padding
        )
    }
    
}