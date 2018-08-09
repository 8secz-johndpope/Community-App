//
//  ShelfCell.swift
//  community
//
//  Created by Jonathan Landon on 8/2/18.
//

import UIKit
import Alexandria

final class ShelfCell: CollectionViewCell {
    
    private let iconView    = UILabel()
    private let titleLabel  = UILabel()
    private let chevronView = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? .lightest : .lightBackground
        }
    }
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        
        iconView.add(toSuperview: contentView).customize {
            $0.pinCenterX(to: contentView, .leading, plus: .padding * 2).pinCenterY(to: contentView)
            $0.constrainSize(toFit: .vertical, .horizontal)
            $0.font = .fontAwesome(.solid, size: 20)
            $0.textColor = .dark
        }
        
        titleLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding * 3.5)
            $0.pinCenterY(to: contentView).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 18)
            $0.textColor = .dark
        }
        
        chevronView.add(toSuperview: contentView).customize {
            $0.pinTrailing(to: contentView, plus: -.padding).pinLeading(to: titleLabel, .trailing, plus: .padding)
            $0.pinCenterY(to: contentView).constrainSize(toFit: .vertical, .horizontal)
            $0.textColor = .dark
            $0.font = .fontAwesome(.light, size: 15)
            $0.set(icon: .chevronRight)
        }
    }
    
    func configure(shelf: Contentful.Shelf) {
        iconView.set(icon: shelf.icon)
        titleLabel.text = shelf.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.text = nil
        titleLabel.text = nil
    }
    
}
