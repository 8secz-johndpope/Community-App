//
//  UIImageView+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Nuke

extension UIImageView {
    
    @discardableResult
    public func setImage(with url: URL?, completion: @escaping () -> Void = {}) -> ImageTask? {
        
        guard let url = url else {
            completion()
            return nil
        }
        
        let task = ImagePipeline.shared.loadImage(with: url) { response, error in
            self.image = response?.image
            completion()
        }
        
        return task
    }
    
}
