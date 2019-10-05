//
//  SearchSuggestionCell.swift
//  community
//
//  Created by Jonathan Landon on 8/10/18.
//

import UIKit
import Diakoneo

final class SearchSuggestionCell: CollectionViewCell {
    
    private let iconView    = UILabel()
    private let titleLabel  = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? .backgroundAlt : .background
        }
    }
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        
        iconView.add(toSuperview: contentView).customize {
            $0.pinCenterX(to: contentView, .leading, plus: .padding * 2).pinCenterY(to: contentView)
            $0.constrainSize(toFit: .vertical, .horizontal)
            $0.font = .fontAwesome(.regular, size: 16)
            $0.textColor = .text
            $0.set(icon: .search)
        }
        
        titleLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding * 3.5).pinTrailing(to: contentView, plus: -.padding)
            $0.pinCenterY(to: contentView).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 18)
            $0.textColor = .text
        }
    }
    
    func configure(suggestion: String) {
        titleLabel.text = suggestion
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    static func size(forSuggestion suggestion: String, in collectionView: UICollectionView) -> CGSize {
        return CGSize(width: collectionView.width, height: 44)
    }
    
}
