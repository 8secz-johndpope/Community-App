//
//  HeaderCell.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Diakoneo

final class HeaderCell: CollectionViewCell {
    
    private let titleLabel    = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10, trailingBuffer: 50)
    private let subtitleLabel = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        titleLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView).pinTrailing(to: contentView)
            $0.pinTop(to: contentView).constrainSize(toFit: .vertical)
            $0.textColor = .dark
            $0.font = .header
        }
        
        subtitleLabel.add(toSuperview: contentView).customize {
            $0.pinTop(to: titleLabel, .bottom).pinBottom(to: contentView)
            $0.pinLeading(to: contentView).pinTrailing(to: contentView)
            $0.textColor = .dark
            $0.font = .subHeader
            $0.numberOfLines = 0
        }
    }
    
    func configure(title: String, subtitle: String) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    static func size(ofTitle title: String, subtitle: String, in collectionView: UICollectionView) -> CGSize {
        
        let width = collectionView.width - .padding * 2
        
        let titleHeight = title.size(font: .header).height
        let subtitleHeight = subtitle.size(boundingWidth: width, font: .subHeader).height
        
        return CGSize(
            width: width,
            height: (titleHeight + subtitleHeight).rounded(.up)
        )
    }
    
}
