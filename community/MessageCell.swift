//
//  MessageCell.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

final class MessageCell: CollectionViewCell {
    
    private let containerView = ContainerShadowView()
    private let imageView     = LoadingImageView()
    private let infoView      = UIView()
    private let titleLabel    = UILabel()
    private let speakerLabel  = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        containerView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .white
            $0.containerCornerRadius = 3
        }
        
        imageView.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container).pinTrailing(to: containerView.container)
            $0.pinTop(to: containerView.container)
            $0.contentMode = .scaleAspectFill
            $0.isHidden = true
            $0.clipsToBounds = true
        }
        
        infoView.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container).pinTrailing(to: containerView.container)
            $0.pinBottom(to: containerView.container).pinTop(to: imageView, .bottom)
            $0.constrainHeight(to: .infoHeight)
        }
        
        let holderView = UIView(superview: infoView).customize {
            $0.pinLeading(to: infoView, plus: .padding).pinTrailing(to: infoView, plus: -.padding)
            $0.pinCenterY(to: infoView)
            $0.backgroundColor = .white
        }
        
        titleLabel.add(toSuperview: holderView).customize {
            $0.pinLeading(to: holderView).pinTrailing(to: holderView)
            $0.pinTop(to: holderView).constrainSize(toFit: .vertical)
            $0.font = .bold(size: 16)
            $0.textColor = .dark
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
        speakerLabel.add(toSuperview: infoView).customize {
            $0.pinLeading(to: holderView).pinTrailing(to: holderView)
            $0.pinTop(to: titleLabel, .bottom).pinBottom(to: holderView)
            $0.constrainSize(toFit: .vertical)
            $0.font = .regular(size: 12)
            $0.textColor = .dark
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
    }
    
    func configure(message: Watermark.Message) {
        titleLabel.text = message.title
        speakerLabel.text = message.speakers.map { $0.name }.joined(separator: ", ")
        
        if let image = message.wideImage {
            imageView.isHidden = false
            imageView.load(url: image.url)
        }
        else {
            imageView.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        speakerLabel.text = nil
        
        imageView.cancel()
        imageView.isHidden = true
    }
    
}
