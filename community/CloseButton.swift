//
//  CloseButton.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

final class CloseButton: UIButton {
    
    override var tintColor: UIColor! {
        didSet {
            setTitleColor(tintColor, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
}

extension CloseButton {
    
    private func setup() {
        setTitle(Icon.close.string, for: .normal)
        titleLabel?.font = .fontAwesome(.light, size: 24)
        configure(normal: .lightBackground, highlighted: .lightest)
    }
    
    func configure(normal: UIColor, highlighted: UIColor) {
        setTitleColor(normal, for: .normal)
        setTitleColor(highlighted, for: .highlighted)
    }
    
}
