//
//  TableHeaderView.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import UIKit
import Diakoneo

final class TableHeaderView: View {
    
    private let titleLabel    = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10, trailingBuffer: 50)
    private let subtitleLabel = UILabel()
    private let videoButton   = UIButton()
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
        
        constrain(.height, .greaterThanOrEqual, to: 64)
        
        titleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -(.padding + 45))
            $0.pinTop(to: self).constrainSize(toFit: .vertical)
            $0.backgroundColor = .clear
        }
        
        subtitleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom).pinBottom(to: self, relation: .greaterThanOrEqual)
            $0.constrainSize(toFit: .vertical)
            $0.backgroundColor = .clear
            $0.numberOfLines = 2
        }
        
        videoButton.add(toSuperview: self).customize {
            $0.pinTop(to: titleLabel).pinTrailing(to: self, plus: -.padding)
            $0.constrainHeight(to: 45).constrainWidth(to: 45)
            $0.setTitle(Icon.video.string, for: .normal)
            $0.setTitleColor(.lightBackground, for: .normal)
            $0.setTitleColor(.light, for: .highlighted)
            $0.contentHorizontalAlignment = .right
            $0.adjustsImageWhenHighlighted = false
            $0.titleLabel?.font = .fontAwesome(.solid, size: 27)
            $0.titleEdgeInsets = UIEdgeInsets(top: 5)
            $0.addTarget(for: .touchUpInside) { [weak self] in
                guard let self = self else { return }
                let buttonFrame = self.convert(self.videoButton.frame, to: AppDelegate.shared.window)
                VideoViewController().show(buttonMinY: buttonFrame.minY)
                Analytics.viewedIntroView()
            }
        }
    }
    
    func configure(table: Contentful.Table?) {
        titleLabel.attributedText    = table?.title.attributed.font(.header).color(.lightBackground)
        subtitleLabel.attributedText = table?.info.attributed.font(.subHeader).color(.lightBackground)
    }
    
}
