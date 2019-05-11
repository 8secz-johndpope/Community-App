//
//  UIView+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import Alexandria

extension UILayoutGuide {
    
    convenience init(superview: UIView) {
        self.init()
        superview.addLayoutGuide(self)
    }
    
}

extension UIView.AnimationCurve {
    var animationOptionsCurve: UIView.AnimationOptions {
        switch self {
        case .easeInOut:  return .curveEaseInOut
        case .easeIn:     return .curveEaseIn
        case .easeOut:    return .curveEaseOut
        case .linear:     return .curveLinear
        @unknown default: return .curveLinear
        }
    }
}

extension UIView {
    
    var safeInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        }
        else {
            return .zero
        }
    }
    
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
    
    func constrainClose(width: CGFloat = .closeButtonWidth, height: CGFloat = .closeButtonWidth) {
        constrainWidth(to: width).constrainHeight(to: height)
    }
    
    func pinBetween(topAnchor: NSLayoutYAxisAnchor, bottomAnchor: NSLayoutYAxisAnchor, in superview: UIView, atPriority priority: UILayoutPriority = .required) {
        
        let topGuide = UILayoutGuide(superview: superview).customize {
            $0.leadingAnchor.constraint(equalTo: superview.leadingAnchor).customize {
                $0.priority = priority
                $0.isActive = true
            }
            $0.trailingAnchor.constraint(equalTo: superview.trailingAnchor).customize {
                $0.priority = priority
                $0.isActive = true
            }
            $0.topAnchor.constraint(equalTo: topAnchor).customize {
                $0.priority = priority
                $0.isActive = true
            }
            $0.bottomAnchor.constraint(equalTo: self.topAnchor).customize {
                $0.priority = priority
                $0.isActive = true
            }
        }
        
        UILayoutGuide(superview: superview).customize {
            $0.leadingAnchor.constraint(equalTo: superview.leadingAnchor).customize {
                $0.priority = priority
                $0.isActive = true
            }
            $0.trailingAnchor.constraint(equalTo: superview.trailingAnchor).customize {
                $0.priority = priority
                $0.isActive = true
            }
            $0.topAnchor.constraint(equalTo: self.bottomAnchor).customize {
                $0.priority = priority
                $0.isActive = true
            }
            $0.bottomAnchor.constraint(equalTo: bottomAnchor).customize {
                $0.priority = priority
                $0.isActive = true
            }
            $0.heightAnchor.constraint(equalTo: topGuide.heightAnchor).customize {
                $0.priority = priority
                $0.isActive = true
            }
        }
    }
    
    func pinBottomToTopSafeArea(in controller: UIViewController, plus: CGFloat = 0) {
        if #available(iOS 11, *) {
            pinSafely(.bottom, to: controller.view, .top, plus: plus)
        }
        else {
            pinBottom(to: controller.topLayoutGuide, plus: plus)
        }
    }
    
}

extension UIView {
    
    public enum GestureType {
        case tap
        case longPress
        case pan
        case swipe(UISwipeGestureRecognizer.Direction)
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
