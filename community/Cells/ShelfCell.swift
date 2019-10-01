//
//  ShelfCell.swift
//  community
//
//  Created by Jonathan Landon on 8/2/18.
//

import UIKit
import Diakoneo

final class ShelfCell: CollectionViewCell {
    
    private let titleLabel  = UILabel()
    private let chevronView = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? .lightest : .clear
        }
    }
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        
        titleLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding)
            $0.pinCenterY(to: contentView).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 18)
            $0.textColor = .dark
        }
        
        chevronView.add(toSuperview: contentView).customize {
            $0.pinTrailing(to: contentView, plus: -.padding).pinLeading(to: titleLabel, .trailing, plus: .padding)
            $0.pinCenterY(to: contentView).constrainSize(toFit: .vertical, .horizontal)
            $0.textColor = .dark
            $0.font = .fontAwesome(.regular, size: 18)
            $0.set(icon: .angleRight)
        }
    }
    
    func configure(shelf: Contentful.Shelf) {
        titleLabel.text = shelf.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    static func size(ofShelf shelf: Contentful.Shelf, in collectionView: UICollectionView) -> CGSize {
        return CGSize(
            width: collectionView.width,
            height: 50
        )
    }
    
}
