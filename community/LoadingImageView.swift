//
//  LoadingImageView.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Alexandria
import Nuke

final class LoadingImageView: UIImageView {
    
    private let loadingGradientView = GradientView(gradient: .empty)
    private let dimmerView          = UIView()
    
    private var imageTask: ImageTask?
    
    override var image: UIImage? {
        didSet {
            if image == nil {
                animate()
            }
            else {
                shutdown()
            }
        }
    }
    
    var showDimmer = false {
        didSet {
            dimmerView.isHidden = !showDimmer
        }
    }
    
    required init(showDimmer: Bool = false) {
        super.init(frame: .zero)
        self.setup()
        self.showDimmer = showDimmer
        self.dimmerView.isHidden = !showDimmer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .lightest
        accessibilityIgnoresInvertColors = true
        
        dimmerView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .dimmer
            $0.isHidden = true
        }
        
        loadingGradientView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.isHidden = true
        }
    }
    
    func load(url: URL?, placeholder: UIImage? = nil, completion: @escaping () -> Void = {}) {
        cancel()
        animate()
        
        image = placeholder
        
        imageTask = setImage(with: url) { [weak self] in
            self?.shutdown()
            completion()
        }
    }
    
    func cancel() {
        shutdown()
        imageTask?.cancel()
        imageTask = nil
        image = nil
    }
    
}

extension LoadingImageView {
    
    private func animate() {
        guard isReadyToAnimate, image == nil else {
            loadingGradientView.isHidden = true
            return
        }
        
        shutdown()
        
        loadingGradientView.isHidden = false
        loadingGradientView.animate(with: .emptyDark)
    }
    
    private func shutdown() {
        layer.removeAllAnimations()
        loadingGradientView.isHidden = true
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        animate()
    }
    
    override open func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            shutdown()
        }
    }
    
    override open func didMoveToWindow() {
        if self.window == nil {
            shutdown()
        }
        else {
            animate()
        }
    }
    
}
