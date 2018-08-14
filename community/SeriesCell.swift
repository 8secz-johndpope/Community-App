//
//  SeriesCell.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

final class SeriesCell: CollectionViewCell {
    
    private let containerView = ContainerShadowView()
    private let imageView     = LoadingImageView()
    private let titleLabel    = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        containerView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .lightBackground
            $0.containerCornerRadius = 8
        }
        
        imageView.add(toSuperview: containerView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.contentMode = .scaleAspectFill
            $0.isHidden = true
            $0.clipsToBounds = true
        }
        
        titleLabel.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinCenterY(to: containerView.container).constrainSize(toFit: .vertical)
            $0.numberOfLines = 3
            $0.font = .semiBold(size: 20)
            $0.textColor = .dark
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
