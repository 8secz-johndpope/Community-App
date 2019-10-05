//
//  SeriesMessageCell.swift
//  community
//
//  Created by Jonathan Landon on 7/31/18.
//

import UIKit
import Diakoneo

final class SeriesMessageCell: CollectionViewCell {
    
    private let containerView    = ContainerShadowView()
    private let titleLabel       = UILabel()
    private let speakerImageView = LoadingImageView()
    private let speakerLabel     = UILabel()
    
    private var speakerLabelConstraint: NSLayoutConstraint?
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        containerView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .background
            $0.containerCornerRadius = 4
        }
        
        titleLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinTop(to: containerView.container, plus: .padding).constrainSize(toFit: .vertical)
            $0.font = .bold(size: 16)
            $0.textColor = .text
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
        speakerImageView.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTop(to: titleLabel, .bottom, plus: 10)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.cornerRadius = 15
            $0.contentMode = .scaleAspectFill
            $0.defaultGradient = .empty
            $0.backgroundColor = .backgroundAlt
        }
        
        speakerLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: speakerImageView, .trailing, plus: .padding, atPriority: .required - 2).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinCenterY(to: speakerImageView).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 12)
            $0.textColor = .text
            $0.numberOfLines = 1
            
            speakerLabelConstraint = $0.constrain(.leading, to: containerView.container, .leading, plus: .padding)
            speakerLabelConstraint?.isActive = false
        }
    }
    
    func configure(message: Watermark.Message) {
        titleLabel.text = message.title
        speakerLabel.text = message.speakers.map { $0.name }.joined(separator: ", ")
        
        if let image = message.speakers.first?.image {
            speakerImageView.isHidden = false
            speakerImageView.load(url: image)
            speakerLabelConstraint?.isActive = false
        }
        else {
            speakerImageView.isHidden = true
            speakerLabelConstraint?.isActive = true
        }
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
        let bottomHeight: CGFloat = (message.speakers.first?.image == nil) ? 20 : 30
        
        return CGSize(
            width: cellWidth,
            height: .padding + titleHeight + 10 + bottomHeight + .padding
        )
    }
    
}
