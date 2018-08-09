//
//  SelfSizingCollectionView.swift
//  community
//
//  Created by Jonathan Landon on 8/6/18.
//

import UIKit
import Alexandria

class SelfSizingCollectionView: UICollectionView {
    
    private lazy var heightConstraint: NSLayoutConstraint = self.constrain(.height, to: 0, atPriority: .required - 1)
    
    override var contentSize: CGSize {
        didSet { heightConstraint.constant = contentSize.height }
    }
}
