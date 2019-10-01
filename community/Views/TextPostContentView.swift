//
//  TextPostContentView.swift
//  community
//
//  Created by Jonathan Landon on 1/19/19.
//

import UIKit
import Diakoneo

final class TextPostContentView: View {
    
    private let textView = SelfSizingTextView(frame: .zero)
    
    override func setup() {
        super.setup()
        
        textView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview(top: 10, bottom: .padding)
            $0.textContainerInset = UIEdgeInsets(inset: .textInset)
            $0.backgroundColor = .lightBackground
            $0.isEditable = false
            $0.isSelectable = true
            $0.delegate = self
            $0.linkTextAttributes = [.foregroundColor : UIColor.lightBlue]
        }
    }
    
    func configure(textPost: Contentful.TextPost) {
        textView.attributedText = textPost.content.renderMarkdown
    }
}

extension TextPostContentView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let image = (textAttachment as? AsyncTextAttachment)?.image {
            print("Image: \(image)")
        }
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if interaction == .presentActions {
            DeepLink.url(URL).handle()
        }
        return false
    }
    
}
