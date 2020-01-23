//
//  EpisodeCell.swift
//  community
//
//  Created by Jonathan Landon on 1/21/20.
//

import UIKit
import Diakoneo

final class EpisodeCell: CollectionViewCell {
    
    private let titleLabel    = UILabel()
    private let speakersLabel = UILabel()
    private let dateLabel     = UILabel()
    private let playView      = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.backgroundColor = .background
        cornerRadius = 8
        borderColor = .separator
        borderWidth = 1
        
        let stackView = UIStackView(superview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
            $0.pinCenterY(to: contentView)
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
        }
        
        playView.add(toSuperview: contentView).customize {
            $0.pinLeading(to: stackView, .trailing, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.pinCenterY(to: contentView)
            $0.cornerRadius = 15
            $0.backgroundColor = .separator
            $0.textAlignment = .center
            $0.font = .fontAwesome(.solid, size: 12)
            $0.textColor = .white
            $0.text = String(format: " %C", Icon.play.rawValue)   // include 1/6 em space character for proper alignment
            $0.isHidden = true
        }
        
        titleLabel.add(toStackview: stackView).customize {
            $0.constrainSize(toFit: .vertical)
            $0.numberOfLines = 0
            $0.font = .crimsonText(.semiBold, size: 22)
            $0.textColor = .text
        }
        
        speakersLabel.add(toStackview: stackView).customize {
            $0.constrainSize(toFit: .vertical)
            $0.font = .karla(.italic, size: 14)
            $0.textColor = .text
        }
        
        dateLabel.add(toStackview: stackView).customize {
            $0.constrainSize(toFit: .vertical)
            $0.font = .karla(.bold, size: 14)
            $0.textColor = .text
        }
        
        stackView.setCustomSpacing(10, after: titleLabel)
        stackView.setCustomSpacing(5, after: speakersLabel)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        borderColor = .separator
    }
    
    func configure(episode: Contentful.Post) {
        titleLabel.text = episode.title
        speakersLabel.text = episode.authors.map { $0.name }.joined(separator: ", ")
        dateLabel.text = DateFormatter.readable.string(from: episode.publishDate)
        
        speakersLabel.isHidden = episode.authors.isEmpty
    }
    
    static func size(forEpisode episode: Contentful.Post, in view: UIView) -> CGSize {
        let width = view.width - .padding * 2
        let textWidth = width - .padding * 2
        
        let titleHeight = episode.title.size(boundingWidth: textWidth, font: .crimsonText(.semiBold, size: 22)).height
        let speakerHeight = episode.authors.isEmpty ? 0 : ("—".size(boundingWidth: textWidth, font: .karla(.italic, size: 14)).height + 5)
        let dateHeight = DateFormatter.readable.string(from: episode.publishDate).size(boundingWidth: textWidth, font: .karla(.bold, size: 14)).height
        
        let height = .padding + titleHeight.rounded(.up) + 10 + speakerHeight + dateHeight.rounded(.up) + .padding
        
        return CGSize(
            width: width,
            height: height
        )
    }
    
}
