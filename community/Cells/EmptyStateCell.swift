//
//  EmptyStateCell.swift
//  community
//
//  Created by Jonathan Landon on 1/22/20.
//

import UIKit
import Diakoneo

final class EmptyStateCell: CollectionViewCell {
    
    private let label = UILabel()
    
    override func setup() {
        super.setup()
        
        label.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.font = .regular(size: 16)
            $0.textColor = .text
        }
    }
    
    func configure(text: String) {
        label.text = text
    }
    
}
