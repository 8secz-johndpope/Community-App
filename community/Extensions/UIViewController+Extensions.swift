//
//  UIViewController+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

extension UIViewController {
    
    static func isCurrentPlaying(content: ContentViewController.Content?) -> Bool {
        return (current as? ContentViewController)?.content == content
    }
    
}

protocol ReloadingViewController: class {
    var refreshControl: UIRefreshControl { get }
}

extension UIViewController {
    
    @objc dynamic func reloadContent() {
        Content.loadAll { [weak self] in
            DispatchQueue.main.async {
                (self as? ReloadingViewController)?.refreshControl.endRefreshing()
            }
        }
    }
    
}
