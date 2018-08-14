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
    public func setImage(with url: URL?, completion: @escaping (Bool) -> Void = { _ in }) -> ImageTask? {
        
        guard let url = url else {
            completion(false)
            return nil
        }
        
        let task = ImagePipeline.shared.loadImage(with: url) { response, error in
            if let error = error {
                print("Error loading image: \(url) (\(error.localizedDescription))")
            }
            self.image = response?.image
            completion(response?.image != nil)
        }
        
        return task
    }
    
}
