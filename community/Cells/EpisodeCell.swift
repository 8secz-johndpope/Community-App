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
    
    override func setup() {
        super.setup()
        
        contentView.backgroundColor = .background
        cornerRadius = 8
        borderColor = .separator
        borderWidth = 1
        
        titleLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
            $0.pinTop(to: contentView, plus: .padding).constrainSize(toFit: .vertical)
            $0.numberOfLines = 0
            $0.font = .crimsonText(.semiBold, size: 22)
            $0.textColor = .text
        }
        
        speakersLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom, plus: 10).constrainSize(toFit: .vertical)
            $0.font = .karla(.italic, size: 14)
            $0.textColor = .text
        }
        
        dateLabel.add(toSuperview: contentView).customize {
            $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
            $0.pinTop(to: speakersLabel, .bottom, plus: 5).constrainSize(toFit: .vertical)
            $0.font = .karla(.bold, size: 14)
            $0.textColor = .text
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        borderColor = .separator
    }
    
    func configure(episode: Contentful.Post) {
        titleLabel.text = episode.title
        speakersLabel.text = "—"
        dateLabel.text = DateFormatter.readable.string(from: episode.publishDate)
    }
    
    static func size(forEpisode episode: Contentful.Post, in view: UIView) -> CGSize {
        let width = view.width - .padding * 2
        let textWidth = width - .padding * 2
        
        let titleHeight = episode.title.size(boundingWidth: textWidth, font: .crimsonText(.semiBold, size: 22)).height
        let speakerHeight = "—".size(boundingWidth: textWidth, font: .karla(.italic, size: 14)).height
        let dateHeight = DateFormatter.readable.string(from: episode.publishDate).size(boundingWidth: textWidth, font: .karla(.bold, size: 14)).height
        
        let height = .padding + titleHeight.rounded(.up) + 10 + speakerHeight.rounded(.up) + 5 + dateHeight.rounded(.up) + .padding
        
        return CGSize(
            width: width,
            height: height
        )
    }
    
}
