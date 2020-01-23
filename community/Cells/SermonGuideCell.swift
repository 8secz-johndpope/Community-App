//
//  SermonGuideCell.swift
//  community
//
//  Created by Jonathan Landon on 1/21/20.
//

import UIKit
import Diakoneo

final class SermonGuideCell: CollectionViewCell {
    
    private let containerView = ContainerShadowView()
    private let imageView     = LoadingImageView()
    private let titleLabel    = UILabel()
    private let dateLabel     = UILabel()
    private let blurView      = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let readLabel     = UILabel()
    
    override func setup() {
        super.setup()
        
        containerView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.containerCornerRadius = 8
        }
        
        imageView.add(toSuperview: containerView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.contentMode = .scaleAspectFill
            $0.showDimmer = true
        }

        blurView.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container).pinTrailing(to: containerView.container)
            $0.pinBottom(to: containerView.container).constrainHeight(to: 60)
            
            if #available(iOS 13, *) {
                blurView.effect = UIBlurEffect(style: .systemChromeMaterialDark)
            }
        }

        readLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinCenterY(to: blurView).constrainSize(toFit: .vertical)
            $0.font = .karla(.regular, size: 14)
            $0.textColor = .white
            $0.text = "View Sermon Guide"
        }
        
        dateLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinBottom(to: blurView, .top, plus: -.padding).constrainSize(toFit: .vertical)
            $0.font = .karla(.regular, size: 14)
            $0.textColor = .white
        }
        
        titleLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinBottom(to: dateLabel, .top, plus: -5).constrainSize(toFit: .vertical)
            $0.numberOfLines = 0
            $0.font = .crimsonText(.semiBold, size: 25)
            $0.textColor = .white
        }
        
    }
    
    func configure(guide: Contentful.Post) {
        imageView.load(url: guide.image)
        titleLabel.text = guide.title
        dateLabel.text = DateFormatter.readable.string(from: guide.publishDate)
    }
    
}
