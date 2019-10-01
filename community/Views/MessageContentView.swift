//
//  MessageContentView.swift
//  community
//
//  Created by Jonathan Landon on 1/19/19.
//

import UIKit
import Diakoneo
import Alexandria

final class MessageContentView: View {
    
    private let titleLabel      = UILabel()
    private let subtitleLabel   = UILabel()
    private let descriptionView = SelfSizingTextView()
    
    override func setup() {
        super.setup()
        
        titleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.pinTop(to: self, plus: 30).constrainSize(toFit: .vertical)
            $0.numberOfLines = 0
            $0.font = .bold(size: 22)
            $0.textColor = .dark
            $0.textAlignment = .left
        }
        
        subtitleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom, plus: 10).constrainSize(toFit: .vertical)
            $0.numberOfLines = 0
        }
        
        descriptionView.add(toSuperview: self).customize {
            $0.pinTop(to: subtitleLabel, .bottom)
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.textContainerInset = UIEdgeInsets(inset: .textInset)
            $0.backgroundColor = .lightBackground
            $0.isEditable = false
            $0.isSelectable = true
            $0.delegate = self
            $0.linkTextAttributes = [.foregroundColor : UIColor.orange]
        }
    }
    
    func configure(message: Watermark.Message) {
        
        titleLabel.text = message.title
        
        subtitleLabel.attributedText = (
            message.speakers.map { $0.name }.joined(separator: ", ").attributed.font(.bold(size: 16)) +
            "\n\(DateFormatter.readable.string(from: message.date))".attributed.font(.regular(size: 16))
        ).color(.dark)
        
        descriptionView.attributedText = message.details.attributed
            .color(.dark)
            .font(.regular(size: 16))
            .lineSpacing(5)
        
        if !message.scriptureReferences.isEmpty {
            
            let scriptureReferenceTitleLabel = UILabel(superview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
                $0.pinTop(to: descriptionView, .bottom).constrainSize(toFit: .vertical)
                $0.font = .bold(size: 18)
                $0.textColor = .dark
                $0.text = "Scripture References"
            }
            
            ScriptureReferenceCollectionView().add(toSuperview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
                $0.pinTop(to: scriptureReferenceTitleLabel, .bottom, plus: 10).pinBottom(to: self, plus: -.padding * 2)
                $0.configure(references: message.scriptureReferences.map { $0.reference })
            }
        }
        else {
            descriptionView.pinBottom(to: self, plus: -.padding * 2)
        }
    }
    
}

extension MessageContentView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if interaction == .presentActions {
            UIViewController.current?.showInSafari(url: URL)
        }
        return false
    }
    
}
