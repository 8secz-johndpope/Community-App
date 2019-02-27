//
//  UIViewController+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import SafariServices

extension UIViewController {
    
    static func isCurrentPlaying(content: ContentViewController.Content?) -> Bool {
        return (current as? ContentViewController)?.content == content
    }
    
    func show(in controller: UIViewController? = .current, animated: Bool = true, completion: @escaping () -> Void = {}) {
        controller?.present(self, animated: animated, completion: completion)
    }
    
    func showInSafari(url: URL?) {
        guard let url = url else { return }
        SFSafariViewController(url: url).show(in: self)
    }
    
    static func comingSoon() {
        UIAlertController.alert(title: "Coming Soon!").addAction(title: "OK").present()
    }
    
    @objc var pullToDismissOffset: CGFloat {
        return 80
    }
    
    @objc dynamic func userDidPan(_ recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: view)
        
        guard
            let scrollView = recognizer.view as? UIScrollView,
            recognizer.state == .ended,
            scrollView.adjustedOffset.y < -pullToDismissOffset,
            velocity.y > 0
        else { return }
        
        //disable bounces up scroll view
        scrollView.bounces = false
        scrollView.contentInset.top = -scrollView.contentOffset.y
        scrollView.isUserInteractionEnabled = false
        
        dismiss(animated: true)
    }
    
}
