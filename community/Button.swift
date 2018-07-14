//
//  Button.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

class Button: UIButton {
    let backgroundView = ContainerShadowView()
    
    private var currentTransform: CGAffineTransform = .identity
    
    var animationDuration: TimeInterval = 0.5
    var minimumScale: CGFloat = 0.9
    var springDamping: CGFloat = 0.6
    
    var didTap: () -> Void = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    func setup() {
        addActions()
        
        backgroundView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.isUserInteractionEnabled = false
        }
    }
    
}

extension Button {
    
    func addActions() {
        addTarget(for: .touchDown)      { [weak self] in self?.shrink() }
        addTarget(for: .touchDragEnter) { [weak self] in self?.shrink() }
        addTarget(for: .touchCancel)    { [weak self] in self?.expand() }
        addTarget(for: .touchDragExit)  { [weak self] in self?.expand() }
        addTarget(for: .touchUpOutside) { [weak self] in self?.expand() }
        addTarget(for: .touchUpInside)  { [weak self] in
            self?.expand()
            self?.didTap()
        }
    }
    
    private func shrink() {
        currentTransform = backgroundView.transform
        UIView.animate(animationDuration, 0, springDamping, 0, .allowUserInteraction) {
            self.backgroundView.transform = self.currentTransform.scaledBy(x: self.minimumScale, y: self.minimumScale)
        }
    }
    
    private func expand() {
        UIView.animate(animationDuration, 0, springDamping, 0, .allowUserInteraction) {
            self.backgroundView.transform = self.currentTransform
        }
    }
    
}
