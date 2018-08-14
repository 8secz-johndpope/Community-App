//
//  SearchHeaderCell.swift
//  community
//
//  Created by Jonathan Landon on 8/10/18.
//

import UIKit

final class SearchHeaderCell: CollectionViewCell {
    
    private let label = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        label.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview(leading: .padding, trailing: .padding)
            $0.textColor = .dark
            $0.font = .extraBold(size: 20)
            $0.numberOfLines = 0
        }
    }
    
    func configure(text: String) {
        label.text = text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    static func size(forText text: String, in collectionView: UICollectionView) -> CGSize {
        let labelWidth = collectionView.width - .padding * 2
        let height = text.size(boundingWidth: labelWidth, font: .extraBold(size: 20)).height.rounded(.up)
        
        return CGSize(width: collectionView.width, height: height)
    }
    
}
