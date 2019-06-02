//
//  AsyncTextAttachment.swift
//  community
//
//  Created by Oliver Drobnik on 01/09/2016.
//  Copyright © 2016 Cocoanetics. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol AsyncTextAttachmentDelegate: AnyObject {
    func didLoadImage(in textAttachment: AsyncTextAttachment, displaySizeChanged: Bool)
}

class AsyncTextAttachment: NSTextAttachment
{
    var imageURL: URL?
    var displaySize: CGSize?
    var maximumDisplayWidth: CGFloat?
    
    weak var delegate: AsyncTextAttachmentDelegate?
    weak var textContainer: NSTextContainer?
    
    private var downloadTask: URLSessionDataTask?
    private var originalImageSize: CGSize?
    
    init(imageURL: URL? = nil, delegate: AsyncTextAttachmentDelegate? = nil) {
        self.imageURL = imageURL
        self.delegate = delegate
        
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var image: UIImage? {
        didSet {
            originalImageSize = image?.size
        }
    }
    
    // MARK: - Helpers
    
    private func startAsyncImageDownload() {
        guard let imageURL = imageURL, contents == nil, downloadTask == nil else { return }
        
        downloadTask = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            
            defer { self.downloadTask = nil }
            
            guard let data = data, error == nil else { return }
            
            var displaySizeChanged = false
            
            self.contents = data
            
            let ext = imageURL.pathExtension
            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil) {
                self.fileType = uti.takeRetainedValue() as String
            }
            
            if let image = UIImage(data: data) {
                if self.displaySize == nil {
                    displaySizeChanged = true
                }
                
                self.image = image
            }
            
            DispatchQueue.main.async {
                if displaySizeChanged {
                    self.textContainer?.layoutManager?.setNeedsLayout(forAttachment: self)
                }
                else {
                    self.textContainer?.layoutManager?.setNeedsDisplay(forAttachment: self)
                }
                
                self.delegate?.didLoadImage(in: self, displaySizeChanged: displaySizeChanged)
            }
        }
        
        downloadTask?.resume()
    }
    
    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        if let image = image { return image }
        
        guard let contents = contents, let image = UIImage(data: contents) else {
            self.textContainer = textContainer
            startAsyncImageDownload()
            return nil
        }
        
        return image
    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        if let displaySize = displaySize {
            return CGRect(origin: .zero, size: displaySize)
        }
        
        if let imageSize = originalImageSize {
            let maxWidth = maximumDisplayWidth ?? lineFrag.size.width
            let factor = maxWidth / imageSize.width
            
            return CGRect(width: Int(imageSize.width * factor).cgFloat, height: Int(imageSize.height * factor).cgFloat)
        }
        
        return .zero
    }
}
