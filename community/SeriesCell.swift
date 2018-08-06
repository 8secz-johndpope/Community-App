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
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        containerView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .lightBackground
            $0.containerCornerRadius = 4
        }
        
        imageView.add(toSuperview: containerView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.contentMode = .scaleAspectFill
            $0.isHidden = true
            $0.clipsToBounds = true
        }
    }
    
    func configure(series: Watermark.Series) {
        imageView.isHidden = false
        imageView.load(url: series.wideImage?.url)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.cancel()
        imageView.isHidden = true
    }
    
}
