//
//  NotificationPromptCell.swift
//  community
//
//  Created by Jonathan Landon on 1/22/20.
//

import UIKit
import Diakoneo

final class NotificationPromptCell: CollectionViewCell {
    
    private let iconLabel     = UILabel()
    private let contentLabel  = UILabel()
    private let allowButton   = UIButton()
    private let declineButton = UIButton()
    
    var didDecide: (Bool) -> Void = { _ in }
    
    private static let content = "Want to find out when new content is available in the app?"
    
    override func setup() {
        super.setup()
        
        contentView.backgroundColor = .headerBackground
        contentView.cornerRadius = 8
        contentView.clipsToBounds = true
        
        contentLabel.add(toSuperview: contentView).customize {
            $0.pinTop(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
            $0.constrainSize(toFit: .vertical)
            $0.numberOfLines = 0
            $0.textColor = .white
            $0.font = .karla(.regular, size: 16)
            $0.text = NotificationPromptCell.content
        }
        
        iconLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentLabel, .leading, plus: -20)
            $0.pinCenterY(to: contentLabel).constrainSize(toFit: .vertical, .horizontal)
            $0.font = .fontAwesome(.solid, size: 40)
            $0.textColor = .white
            $0.set(icon: .commentExclamation)
        }
        
        let horizontalLine = UIView(superview: contentView).customize {
            $0.pinLeading(to: contentView).pinTrailing(to: contentView)
            $0.pinTop(to: contentLabel, .bottom, plus: .padding).constrainHeight(to: 1)
            $0.backgroundColor = .separator
            $0.alpha = 0.15
        }
        
        declineButton.add(toSuperview: contentView).customize {
            $0.pinTop(to: horizontalLine, .bottom).pinBottom(to: contentView)
            $0.pinLeading(to: contentView).constrainSize(toFit: .horizontal)
            $0.setBackgroundColor(.headerBackground, for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle("     No Thanks     ", for: .normal)
            $0.titleLabel?.font = .karla(.regular, size: 16)
            $0.addTarget(for: .touchUpInside) { [weak self] in self?.didDecide(false) }
        }
        
        let verticalLine = UIView(superview: contentView).customize {
            $0.pinTop(to: declineButton).pinBottom(to: declineButton)
            $0.pinLeading(to: declineButton, .trailing).constrainWidth(to: 1)
            $0.backgroundColor = .separator
            $0.alpha = 0.15
        }
        
        allowButton.add(toSuperview: contentView).customize {
            $0.pinTop(to: declineButton).pinBottom(to: declineButton)
            $0.pinLeading(to: verticalLine, .trailing).pinTrailing(to: contentView)
            $0.setBackgroundColor(.headerBackground, for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle("Allow Notifications", for: .normal)
            $0.titleLabel?.font = .karla(.regular, size: 16)
            $0.addTarget(for: .touchUpInside) { [weak self] in self?.didDecide(true) }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        declineButton.setBackgroundColor(.headerBackground, for: .normal)
        allowButton.setBackgroundColor(.headerBackground, for: .normal)
    }
    
    static func size(in collectionView: UICollectionView) -> CGSize {
        let width = collectionView.width - .padding * 2
        let iconWidth = Icon.commentExclamation.string.size(font: .fontAwesome(.solid, size: 40)).width.rounded(.up)
        let textWidth = width - .padding * 2 - 20 - iconWidth
        
        let textHeight = NotificationPromptCell.content.size(boundingWidth: textWidth, font: .karla(.regular, size: 16)).height.rounded(.up)
        
        return CGSize(
            width: width,
            height: .padding + textHeight + .padding + 1 + 45
        )
    }
    
}
