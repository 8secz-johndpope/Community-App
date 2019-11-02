//
//  ImageViewController.swift
//  community
//
//  Created by Jonathan Landon on 10/14/19.
//

import UIKit
import Diakoneo

final class ImageViewController: ViewController {
    
    enum DismissAnimation {
        case up(velocity: CGFloat)
        case down(velocity: CGFloat)
        
        var velocity: CGFloat {
            switch self {
            case .up(let velocity):   return abs(velocity)
            case .down(let velocity): return abs(velocity)
            }
        }
        
        var duration: TimeInterval {
            return 0.5 - TimeInterval(velocity).map(from: 0...5000, to: 0...0.25).limited(0, 0.25)
        }
    }
    
    let image: UIImage
    
    private let scrollView  = UIScrollView()
    private let imageView   = UIImageView()
    private let closeButton = CloseButton()
    private let shareButton = UIButton()
    
    private var imageConstraints: (top: NSLayoutConstraint, leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint)?
    
    private var isMinZoom: Bool {
        return scrollView.zoomScale == scrollView.minimumZoomScale
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    required init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        view.backgroundColor = .black

        scrollView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .clear
            $0.bounces = true
            $0.alwaysBounceVertical = true
            $0.alwaysBounceHorizontal = false
            $0.bouncesZoom = true
            $0.delegate = self
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.decelerationRate = .fast
            $0.contentInset = .zero
            $0.contentOffset = .zero
            $0.contentInsetAdjustmentBehavior = .never
            $0.panGestureRecognizer.addTarget(self, action: #selector(didPan(gesture:)))
            $0.addGesture(type: .doubleTap) { [weak self] _ in
                guard let self = self else { return }
                
                let minimumZoomScale = self.scrollView.minimumZoomScale
                
                if self.isMinZoom {
                    self.scrollView.setZoomScale(minimumZoomScale * 2, animated: true)
                }
                else {
                    self.scrollView.setZoomScale(minimumZoomScale, animated: true)
                }
            }
        }
        
        imageView.add(toSuperview: scrollView).customize {
            imageConstraints = $0.constrainEdgesToSuperview()
            $0.backgroundColor = .black
            $0.image = image
        }
        
        closeButton.add(toSuperview: view).customize {
            $0.pinTrailing(to: view).pinSafely(.top, to: view)
            $0.constrainClose(height: 50)
            $0.addTarget(for: .touchUpInside) { [weak self] in self?.hide(animation: .down(velocity: 0)) }
            $0.configure(normal: .white, highlighted: .white)
        }
        
        shareButton.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinSafely(.top, to: view)
            $0.constrainClose(height: 50)
            $0.setTitle(Icon.share.string, for: .normal)
            $0.titleLabel?.font = .fontAwesome(.light, size: 24)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white, for: .highlighted)
            $0.addTarget(for: .touchUpInside) { [weak self] in
                guard let self = self else { return }
                
                let controller = UIActivityViewController(activityItems: [self.image], applicationActivities: nil)
                controller.popoverPresentationController?.sourceView = self.view
                controller.show()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMinZoomScale()
    }
    
    @objc private func didPan(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: view).y
        
        if gesture.state == .ended, abs(scrollView.adjustedOffset.y) > 100, isMinZoom {
            scrollView.bounces = false
            scrollView.isUserInteractionEnabled = false
            scrollView.delegate = nil
            scrollView.layer.speed = 0
            
            if scrollView.adjustedOffset.y < 100 {
                hide(animation: .down(velocity: velocity))
            }
            else {
                hide(animation: .up(velocity: velocity))
            }
        }
    }
    
    private func hide(animation: DismissAnimation) {
        let imageView = UIImageView(superview: view).customize {
            $0.frame = view.convert(self.imageView.frame, from: scrollView)
            $0.image = image
        }
        
        scrollView.isHidden = true
        view.isUserInteractionEnabled = false
        
        updateControlVisibility(forceHide: true)
        
        UIView.animate(withDuration: animation.duration, animations: {
            self.view.backgroundColor = .clear
            
            switch animation {
            case .up:   imageView.transform = .translate(0, -self.view.height/2)
            case .down: imageView.transform = .translate(0, self.view.height/2)
            }
        }) { [weak self] _ in
            self?.dismiss(animated: false)
        }
    }
    
    private func updateConstraints() {
        let imageWidth = (imageView.frame == .zero) ? view.bounds.width : imageView.frame.width
        let imageHeight = imageWidth * image.size.height / image.size.width
        
        let yOffset = max(0, (view.bounds.height - imageHeight) / 2)
        imageConstraints?.top.constant = yOffset
        imageConstraints?.bottom.constant = yOffset
        
        let xOffset = max(0, (view.bounds.width - imageWidth) / 2)
        imageConstraints?.leading.constant = xOffset
        imageConstraints?.trailing.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    private func updateMinZoomScale() {
        let widthScale = view.bounds.width / image.size.width
        let heightScale = view.bounds.height / image.size.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = minScale * 5
        scrollView.zoomScale = minScale
    }
    
}

extension ImageViewController: UIScrollViewDelegate {
    
    func updateControlVisibility(forceHide: Bool = false) {
        let isMinZoom = self.isMinZoom
        let isZeroOffset = (scrollView.adjustedOffset.y == 0)
        
        let transform: CGAffineTransform = (isMinZoom && isZeroOffset && !forceHide) ? .identity : .translate(0, -10)
        let alpha: CGFloat = (isMinZoom && isZeroOffset && !forceHide) ? 1 : 0
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
            self.closeButton.transform = transform
            self.closeButton.alpha = alpha
            
            self.shareButton.transform = transform
            self.shareButton.alpha = alpha
        }, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isMinZoom else { return }
        
        let offset = abs(scrollView.adjustedOffset.y)
        view.backgroundColor = UIColor.black.alpha(1 - offset.map(from: 0...500, to: 0...1).limited(0, 0.5))
        updateControlVisibility()
    }
    
    

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
        updateControlVisibility()
    }
    
}
