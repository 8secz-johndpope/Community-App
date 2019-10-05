//
//  SeriesCell.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Diakoneo

final class SeriesCell: CollectionViewCell {
    
    private let containerView = ContainerShadowView()
    private let imageView     = LoadingImageView()
    private let titleLabel    = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        containerView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .background
            $0.containerCornerRadius = 8
        }
        
        imageView.add(toSuperview: containerView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.contentMode = .scaleAspectFill
            $0.isHidden = true
            $0.clipsToBounds = true
            $0.defaultGradient = .empty
            $0.backgroundColor = .backgroundAlt
        }
        
        titleLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinCenterY(to: containerView.container).constrainSize(toFit: .vertical)
            $0.numberOfLines = 3
            $0.font = .bold(size: 20)
            $0.textColor = .text
            $0.textAlignment = .center
        }
    }
    
    func configure(series: Watermark.Series) {
        imageView.isHidden = false
        imageView.load(url: series.image?.url) { [weak self] loaded in
            self?.titleLabel.isHidden = loaded
        }
        titleLabel.text = series.title
        titleLabel.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.cancel()
        imageView.isHidden = true
        
        titleLabel.text = nil
        titleLabel.isHidden = false
    }
    
}
