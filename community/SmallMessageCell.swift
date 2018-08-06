//
//  SmallMessageCell.swift
//  community
//
//  Created by Jonathan Landon on 7/25/18.
//

import UIKit
import Alexandria

final class SmallMessageCell: CollectionViewCell {
    
    private let imageView    = LoadingImageView()
    private let titleLabel   = UILabel()
    private let speakerLabel = UILabel()
    
    override func setup() {
        super.setup()
        
        let shadowView = ContainerShadowView(superview: contentView).customize {
            $0.pinTop(to: contentView).pinBottom(to: contentView)
            $0.pinLeading(to: contentView).constrainWidth(to: $0, .height, times: 16/9)
            $0.containerCornerRadius = 4
            $0.shadowOpacity = 0.1
        }
        
        imageView.add(toSuperview: shadowView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        let holderView = UIView(superview: contentView).customize {
            $0.pinLeading(to: shadowView, .trailing, plus: .padding).pinTrailing(to: contentView)
            $0.pinCenterY(to: contentView)
            $0.backgroundColor = .lightBackground
        }
        
        titleLabel.add(toSuperview: holderView).customize {
            $0.pinLeading(to: holderView).pinTrailing(to: holderView)
            $0.pinTop(to: holderView).constrainSize(toFit: .vertical)
            $0.font = .bold(size: 14)
            $0.textColor = .dark
            $0.textAlignment = .left
            $0.numberOfLines = 2
        }
        
        speakerLabel.add(toSuperview: holderView).customize {
            $0.pinLeading(to: holderView).pinTrailing(to: holderView)
            $0.pinTop(to: titleLabel, .bottom, plus: 5).pinBottom(to: holderView)
            $0.constrainSize(toFit: .vertical)
            $0.font = .regular(size: 12)
            $0.textColor = .dark
            $0.numberOfLines = 1
        }
    }
    
    func configure(message: Watermark.Message) {
        titleLabel.text = message.title
        speakerLabel.text = message.speakers.map { $0.name }.joined(separator: ", ")
        
        imageView.load(url: message.wideImage?.url)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        speakerLabel.text = nil
        
        imageView.cancel()
    }
    
}
