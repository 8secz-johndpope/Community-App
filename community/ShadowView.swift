//
//  ShadowView.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

class ContainerShadowView: ShadowView {
    
    let container = UIView()
    
    override var backgroundColor: UIColor? {
        set {
            container.backgroundColor = newValue
        }
        get {
            return container.backgroundColor
        }
    }
    
    override var clipsToBounds: Bool {
        set {
            container.clipsToBounds = newValue
        }
        get {
            return container.clipsToBounds
        }
    }
    
    var containerCornerRadius: CGFloat = 0 {
        didSet { update() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        container.add(toSuperview: self).constrainEdgesToSuperview()
    }
    
    override func update() {
        container.cornerRadius = containerCornerRadius
        layer.shadowColor      = shadowColor.cgColor
        layer.shadowOffset     = shadowOffset
        layer.shadowRadius     = shadowRadius
        layer.shadowOpacity    = shadowOpacity
        layer.shadowPath       = useShadowPath ? UIBezierPath(roundedRect: layer.bounds, cornerRadius: container.cornerRadius).cgPath : nil
    }
}

class ShadowView: UIView {
    
    var useShadowPath: Bool = true {
        didSet {
            layer.shadowPath = useShadowPath ? UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath : nil
        }
    }
    
    var shadowColor: UIColor = .dark {
        didSet { update() }
    }
    
    var shadowOffset: CGSize = CGSize(width: 0, height: 10) {
        didSet { update() }
    }
    
    var shadowRadius: CGFloat = 20 {
        didSet { update() }
    }
    
    var shadowOpacity: Float = 0.1 {
        didSet { update() }
    }
    
    open func update() {
        layer.shadowColor   = shadowColor.cgColor
        layer.shadowOffset  = shadowOffset
        layer.shadowRadius  = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath    = useShadowPath ? UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath : nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
}
