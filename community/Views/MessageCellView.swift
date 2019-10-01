//
//  MessageCellView.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Diakoneo

final class MessageCellView: View {
    
    private let containerView = ContainerShadowView()
    private let imageView     = LoadingImageView()
    private let infoView      = UIView()
    private let titleLabel    = UILabel()
    private let speakerLabel  = UILabel()
    
    override func setup() {
        super.setup()
        
        clipsToBounds = false
        
        containerView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .lightBackground
            $0.containerCornerRadius = 4
        }
        
        imageView.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container).pinTrailing(to: containerView.container)
            $0.pinTop(to: containerView.container).constrainHeight(to: $0, .width, times: 9/16)
            $0.contentMode = .scaleAspectFill
            $0.isHidden = true
            $0.clipsToBounds = true
            $0.defaultGradient = .empty
            $0.backgroundColor = .lightest
        }
        
        infoView.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container).pinTrailing(to: containerView.container)
            $0.pinTop(to: imageView, .bottom).pinBottom(to: containerView.container)
            $0.backgroundColor = .lightBackground
        }
        
        UIView(superview: infoView).customize {
            $0.pinLeading(to: infoView).pinTrailing(to: infoView)
            $0.pinTop(to: infoView).constrainHeight(to: 1)
            $0.backgroundColor = .lightest
        }
        
        let holderView = UIView(superview: infoView).customize {
            $0.pinLeading(to: infoView, plus: .padding).pinTrailing(to: infoView, plus: -.padding)
            $0.pinTop(to: infoView, plus: .padding/2).pinBottom(to: infoView, plus: -.padding/2)
            $0.backgroundColor = .lightBackground
        }
        
        titleLabel.add(toSuperview: holderView).customize {
            $0.pinLeading(to: holderView).pinTrailing(to: holderView)
            $0.pinTop(to: holderView).constrainSize(toFit: .vertical)
            $0.font = .bold(size: 16)
            $0.textColor = .dark
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
        speakerLabel.add(toSuperview: holderView).customize {
            $0.pinLeading(to: holderView).pinTrailing(to: holderView)
            $0.pinTop(to: titleLabel, .bottom, plus: 5).pinBottom(to: holderView)
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
        
        if let image = message.image {
            imageView.isHidden = false
            imageView.load(url: image.url)
        }
        else {
            imageView.isHidden = true
        }
    }
    
}
