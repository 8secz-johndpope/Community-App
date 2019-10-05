//
//  MediaProgressView.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import UIKit
import Diakoneo

final class MediaProgressView: View {
    
    private(set) var progress: CGFloat = 0 {
        didSet {
            layout()
        }
    }
    
    private var bufferProgress: CGFloat = 0 {
        didSet {
            guard bufferProgress >= 0 else { return }
            bufferView.width = bufferProgress.map(from: 0...1, to: 0...width).limited(0, width)
        }
    }
    
    private let backgroundView = UIView()
    private let bufferView     = UIView()
    private let progressView   = UIView()
    
    override func setup() {
        
        clipsToBounds = true
        constrainHeight(to: .mediaProgressHeight)
        
        backgroundView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.clipsToBounds = false
            $0.backgroundColor = UIColor.headerText.alpha(0.5)
        }
        
        bufferView.add(toSuperview: backgroundView).customize {
            $0.size = CGSize(width: 0, height: .mediaProgressHeight)
            $0.backgroundColor = UIColor.headerText.alpha(0.5)
        }
        
        progressView.add(toSuperview: backgroundView).customize {
            $0.size = CGSize(width: 0, height: .mediaProgressHeight)
            $0.backgroundColor = .headerText
        }
        
    }
    
}

extension MediaProgressView {
    
    func update(progress: CGFloat? = nil, bufferProgress: CGFloat? = nil) {
        self.progress       ?= progress
        self.bufferProgress ?= bufferProgress
    }
    
    private func layout() {
        guard progress >= 0 else { return }
        let offset = progress.map(from: 0...1, to: 0...width).limited(0, width)
        progressView.width = offset
    }
    
}
