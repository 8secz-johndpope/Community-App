//
//  CollectionViewCell.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
    }
}
