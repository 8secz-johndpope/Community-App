//
//  FeaturedSectionView.swift
//  community
//
//  Created by Jonathan Landon on 12/3/19.
//

import UIKit
import Diakoneo

final class FeaturedSectionView: View {
    
    private var featuredSection: Contentful.FeaturedSection?
    
    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronLabel  = UILabel()
    
    override func setup() {
        super.setup()
        
        backgroundColor = .background
        
        titleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.pinTop(to: self).constrainSize(toFit: .vertical, .horizontal)
            $0.backgroundColor = .background
        }
        
        subtitleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: titleLabel).pinTrailing(to: self, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom, plus: 5).pinBottom(to: self, plus: -.padding)
            $0.constrainSize(toFit: .vertical)
            $0.backgroundColor = .background
            $0.numberOfLines = 2
        }
        
        chevronLabel.add(toSuperview: self).customize {
            $0.pinTrailing(to: self, plus: -.padding).pinCenterY(to: self, plus: -.padding/2)
            $0.constrainSize(toFit: .vertical, .horizontal)
            $0.font = .fontAwesome(.light, size: 22)
            $0.set(icon: .angleRight)
            $0.textColor = .text
            $0.isHidden = true
        }
        
        addGesture(type: .tap) { [weak self] _ in self?.featuredSection?.content.handle() }
    }
    
    func configure(featuredSection: Contentful.FeaturedSection) {
        self.featuredSection = featuredSection
        
        titleLabel.attributedText = featuredSection.title.attributed.font(.crimsonText(.semiBold, size: 25)).color(.text)
        subtitleLabel.attributedText = featuredSection.info.attributed.font(.subHeader).color(.text)
        chevronLabel.isHidden = false
    }
    
}
