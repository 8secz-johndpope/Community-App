//
//  UIView+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import Alexandria

extension UIViewAnimationCurve {
    var animationOptionsCurve: UIViewAnimationOptions {
        switch self {
        case .easeInOut: return .curveEaseInOut
        case .easeIn:    return .curveEaseIn
        case .easeOut:   return .curveEaseOut
        case .linear:    return .curveLinear
        }
    }
}

extension UIView {
    
    var isReadyToAnimate: Bool {
        // Check if we have a superview
        if superview == nil {
            return false
        }
        
        // Check if we are attached to a window
        if window == nil {
            return false
        }
        
        // Check if our view controller is ready
        if UIViewController.current != nil {
            if !UIViewController.current!.isViewLoaded {
                return false
            }
        }
        
        return true
    }
    
    var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
        get {
            return layer.cornerRadius
        }
    }
    
    var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            return layer.borderColor.flatMap(UIColor.init(cgColor:))
        }
    }
    
    @discardableResult
    func add(toSuperview superview: UIView, behind view: UIView) -> Self {
        superview.insertSubview(self, belowSubview: view)
        return self
    }
    
    @discardableResult
    func add(toSuperview superview: UIView, at index: Int) -> Self {
        superview.insertSubview(self, at: index)
        return self
    }
    
}

extension UIView {
    
    public enum GestureType {
        case tap
        case longPress
        case pan
        case swipe(UISwipeGestureRecognizerDirection)
        case doubleTap
    }
    
    @discardableResult
    public func addGesture(type: GestureType, delegate: UIGestureRecognizerDelegate? = nil, action: @escaping (UIGestureRecognizer) -> Void) -> UIGestureRecognizer {
        
        let gesture: UIGestureRecognizer
        
        switch type {
        case .tap:                  gesture = UITapGestureRecognizer(action: action)
        case .longPress:            gesture = UILongPressGestureRecognizer(action: action)
        case .pan:                  gesture = UIPanGestureRecognizer(action: action)
        case .swipe(let direction): gesture = UISwipeGestureRecognizer(action: action).customize { $0.direction = direction }
        case .doubleTap:            gesture = UITapGestureRecognizer(action: action).customize { $0.numberOfTapsRequired = 2 }
        }
        
        gesture.delegate = delegate
        addGestureRecognizer(gesture)
        
        return gesture
    }
}
