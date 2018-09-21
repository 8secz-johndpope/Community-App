//
//  SearchSpeakersCell.swift
//  community
//
//  Created by Jonathan Landon on 8/10/18.
//

import UIKit
import Alexandria

final class SearchSpeakersCell: CollectionViewCell {
    
    private var speakers: [Watermark.Speaker] = []
    
    private let collectionView = UICollectionView(layout: .horizontal(itemSpacing: .padding, lineSpacing: .padding, sectionInset: UIEdgeInsets(left: .padding, right: .padding)))
    
    override func setup() {
        super.setup()
        
        backgroundColor = .lightBackground
        
        collectionView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(Cell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .lightBackground
            $0.showsHorizontalScrollIndicator = false
            $0.decelerationRate = .fast
            $0.alwaysBounceHorizontal = true
            $0.clipsToBounds = false
        }
    }
    
    func configure(speakers: [Watermark.Speaker]) {
        self.speakers = speakers
        self.collectionView.reloadData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        speakers = []
        collectionView.reloadData()
        collectionView.contentOffset = .zero
    }
    
    static func size(in collectionView: UICollectionView) -> CGSize {
        return CGSize(width: collectionView.width, height: .searchSpeakerHeight)
    }
    
}

extension SearchSpeakersCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return speakers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueCell(for: indexPath)
        cell.configure(speaker: speakers[indexPath.row])
        return cell
    }
    
}

extension SearchSpeakersCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Cell.size(forSpeaker: speakers[indexPath.row], in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let speaker = self.speakers.at(indexPath.row) else { return }
        UIViewController.current?.showInSafari(url: speaker.watermark)
    }
    
}

extension SearchSpeakersCell {
    
    final class Cell: CollectionViewCell {
        
        private let imageView = LoadingImageView()
        private let nameLabel = UILabel()
        
        private var nameConstraint: NSLayoutConstraint?
        
        override func setup() {
            super.setup()
            
            let shadowView = ContainerShadowView(superview: contentView).customize {
                $0.constrainEdgesToSuperview()
                $0.backgroundColor = .lightBackground
                $0.containerCornerRadius = .searchSpeakerHeight/2
                $0.shadowOpacity = 0.2
            }
            
            imageView.add(toSuperview: shadowView.container).customize {
                $0.pinLeading(to: shadowView.container).constrainWidth(to: $0, .height)
                $0.pinTop(to: shadowView.container).pinBottom(to: shadowView.container)
                $0.contentMode = .scaleAspectFill
            }
            
            nameLabel.add(toSuperview: shadowView.container).customize {
                $0.pinLeading(to: shadowView.container, plus: .padding, atPriority: .required - 2).pinTrailing(to: shadowView.container, plus: -.padding)
                $0.pinCenterY(to: shadowView.container).constrainSize(toFit: .vertical)
                $0.font = .regular(size: 16)
                $0.textColor = .dark
                $0.numberOfLines = 2
                
                nameConstraint = $0.constrain(.leading, to: imageView, .trailing, plus: .padding, atPriority: .required - 1)
            }
            
        }
        
        func configure(speaker: Watermark.Speaker) {
            if let image = speaker.image {
                imageView.isHidden = false
                imageView.load(url: image)
                nameConstraint?.isActive = true
            }
            else {
                imageView.isHidden = true
                nameConstraint?.isActive = false
            }
            nameLabel.text = speaker.name
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            imageView.cancel()
            imageView.isHidden = false
            nameLabel.text = nil
            nameConstraint?.isActive = true
        }
        
        static func size(forSpeaker speaker: Watermark.Speaker, in collectionView: UICollectionView) -> CGSize {
            
            let imageWidth: CGFloat = (speaker.image == nil) ? 0 : .searchSpeakerHeight
            let nameWidth = speaker.name.size(font: .regular(size: 16)).width.rounded(.up)
            let width = (imageWidth + .padding + nameWidth + .padding).limited(50, collectionView.width * 0.8)
            
            return CGSize(width: width, height: collectionView.height)
        }
        
    }
    
}
