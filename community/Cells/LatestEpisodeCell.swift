//
//  LatestEpisodeCell.swift
//  community
//
//  Created by Jonathan Landon on 1/21/20.
//

import UIKit
import Diakoneo

final class LatestEpisodeCell: CollectionViewCell {
        
        private let titleLabel    = UILabel()
        private let subtitleLabel = UILabel()
        private let dateLabel     = UILabel()
        private let button        = UIButton()
        
        override func setup() {
            super.setup()
            
            constrainHeight(to: 400)
            
            contentView.backgroundColor = .clear
            
            button.add(toSuperview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinBottom(to: contentView, plus: -.padding)
                $0.constrainHeight(to: 30).constrainSize(toFit: .horizontal)
                $0.setAttributedTitle("  VIEW SHOW NOTES  ".attributed.font(.karla(.bold, size: 12)).kern(1).color(.text), for: .normal)
                $0.setBackgroundColor(.background, for: .normal)
                $0.setBackgroundColor(.backgroundAlt, for: .highlighted)
                $0.cornerRadius = 4
//                $0.addTarget(for: .touchUpInside) { [weak self] in
//                    guard let self = self, let episode = self.episode else { return }
//                    self.delegate?.didSelect(episode: episode, in: self)
//                }
            }
            
            dateLabel.add(toSuperview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinBottom(to: button, .top, plus: -.padding)
                $0.constrainSize(toFit: .vertical, .horizontal)
                $0.font = .karla(.bold, size: 14)
                $0.textColor = .white
            }
            
            subtitleLabel.add(toSuperview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinBottom(to: dateLabel, .top, plus: -5)
                $0.constrainSize(toFit: .vertical, .horizontal)
                $0.font = .karla(.italic, size: 14)
                $0.textColor = .white
            }
            
            titleLabel.add(toSuperview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
                $0.pinBottom(to: subtitleLabel, .top, plus: -10).constrainSize(toFit: .vertical)
                $0.numberOfLines = 0
                $0.font = .crimsonText(.semiBold, size: 25)
                $0.textColor = .white
            }
            
            let leaderTitle = UILabel(superview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
                $0.pinTop(to: contentView, plus: 44).constrainSize(toFit: .vertical)
                $0.textColor = .white
                $0.font = .header
                $0.text = "Leadership Lessons"
            }
            
            UILabel(superview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
                $0.pinTop(to: leaderTitle, .bottom).constrainSize(toFit: .vertical)
                $0.textColor = .white
                $0.font = .subHeader
                $0.numberOfLines = 0
                $0.text = "New Episodes Weekly"
            }
            
//            addGesture(type: .tap) { [weak self] _ in
//                guard let self = self, let episode = self.episode else { return }
//                self.delegate?.didSelect(episode: episode, in: self)
//            }
        }
        
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            button.setBackgroundColor(.background, for: .normal)
            button.setBackgroundColor(.backgroundAlt, for: .highlighted)
        }
        
        func configure(episode: Contentful.Post) {
            //self.episode = episode
            
            titleLabel.text = episode.title
            subtitleLabel.text = "Joe Daly, John Elmore, and Blake Holmes"
            dateLabel.text = DateFormatter.readable.string(from: episode.publishDate)
        }
        
    }
