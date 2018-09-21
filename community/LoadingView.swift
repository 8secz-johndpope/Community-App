//
//  LoadingView.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import UIKit

final class LoadingView: View {
    
    var duration: TimeInterval = 0.9
    
    var color: UIColor = .lightBackground
    
    override var bounds: CGRect {
        didSet {
            if oldValue != bounds && isAnimating {
                setupAnimation()
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }
    
    var isAnimating = false
    
}

extension LoadingView {
    
    private func setupAnimation() {
        
        let beginTime: Double = 0.5
        let strokeStartDuration = (duration + 0.3).limited(0, .greatestFiniteMagnitude)
        let strokeEndDuration = (duration - 0.3).limited(0, .greatestFiniteMagnitude)
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        rotationAnimation.timingFunction = .linear
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.beginTime = beginTime
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = strokeStartDuration + beginTime
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        
        self.layer.sublayers = nil
        
        CAShapeLayer(superlayer: layer).customize {
            $0.fillColor = nil
            $0.strokeColor = color.cgColor
            $0.lineWidth = 2
            $0.backgroundColor = nil
            $0.path = UIBezierPath(
                arcCenter: CGPoint(x: size.width/2, y: size.height/2),
                radius: size.width/2,
                startAngle: -(.pi/2),
                endAngle: .pi * 3/2,
                clockwise: true
            ).cgPath
            $0.frame = CGRect(origin: .zero, size: size)
            $0.lineCap = .round
            $0.add(groupAnimation, forKey: "animation")
        }
    }
    
}

extension LoadingView {
    
    func startAnimating() {
        guard !isAnimating else { return }
        
        alpha = 1
        isHidden = false
        isAnimating = true
        layer.speed = 1
        setupAnimation()
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
            self.isAnimating = false
            self.layer.sublayers?.removeAll()
        }
    }
    
}
