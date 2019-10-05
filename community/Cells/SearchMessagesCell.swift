//
//  SearchMessagesCell.swift
//  community
//
//  Created by Jonathan Landon on 8/10/18.
//

import UIKit
import Diakoneo

final class SearchMessagesCell: CollectionViewCell {
    
    private var messages: [Watermark.Message] = []
    
    private let collectionView = UICollectionView(layout: .horizontal(itemSpacing: .padding/2, lineSpacing: .padding, sectionInset: UIEdgeInsets(left: .padding, right: .padding)))
    
    override func setup() {
        super.setup()
        
        backgroundColor = .background
        
        collectionView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(Cell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .background
            $0.showsHorizontalScrollIndicator = false
            $0.decelerationRate = .fast
            $0.alwaysBounceHorizontal = true
            $0.clipsToBounds = false
        }
    }
    
    func configure(messages: [Watermark.Message]) {
        self.messages = messages
        self.collectionView.reloadData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messages = []
        collectionView.reloadData()
        collectionView.contentOffset = .zero
    }
    
    static func size(forMessages messages: [Watermark.Message], in collectionView: UICollectionView) -> CGSize {
        if messages.count == 1 {
            return CGSize(width: collectionView.width, height: .searchMessageHeight)
        }
        else {
            return CGSize(width: collectionView.width, height: .searchMessageHeight * 2 + .padding/2)
        }
    }
    
}

extension SearchMessagesCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueCell(for: indexPath)
        cell.configure(message: messages[indexPath.row])
        return cell
    }
    
}

extension SearchMessagesCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.width - .padding * 2) * 0.9, height: .searchMessageHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let message = self.messages.at(indexPath.row) else { return }
        ContentViewController(message: message).show()
    }
    
}

extension SearchMessagesCell {
    
    final class Cell: CollectionViewCell {
        
        private let imageView    = LoadingImageView()
        private let titleLabel   = UILabel()
        private let speakerLabel = UILabel()
        
        override func setup() {
            super.setup()
            
            let shadowView = ContainerShadowView(superview: contentView).customize {
                $0.pinTop(to: contentView).pinBottom(to: contentView)
                $0.pinLeading(to: contentView).constrainWidth(to: $0, .height, times: 4/3)
                $0.backgroundColor = .loading
                $0.containerCornerRadius = 8
                $0.shadowOpacity = 0.2
            }
            
            imageView.add(toSuperview: shadowView.container).customize {
                $0.constrainEdgesToSuperview()
                $0.contentMode = .scaleAspectFill
                $0.defaultGradient = .empty
                $0.backgroundColor = .backgroundAlt
            }
            
            let holderView = UIView(superview: contentView).customize {
                $0.pinLeading(to: shadowView, .trailing, plus: .padding).pinTrailing(to: contentView)
                $0.pinCenterY(to: contentView)
            }
            
            titleLabel.add(toSuperview: holderView).customize {
                $0.pinLeading(to: holderView).pinTrailing(to: holderView)
                $0.pinTop(to: holderView).constrainSize(toFit: .vertical)
                $0.font = .bold(size: 16)
                $0.textColor = .text
                $0.numberOfLines = 2
            }
            
            speakerLabel.add(toSuperview: holderView).customize {
                $0.pinLeading(to: holderView).pinTrailing(to: holderView)
                $0.pinTop(to: titleLabel, .bottom, plus: 10).pinBottom(to: holderView)
                $0.constrainSize(toFit: .vertical)
                $0.font = .regular(size: 14)
                $0.textColor = .text
            }
            
        }
        
        func configure(message: Watermark.Message) {
            imageView.load(url: message.image?.url)
            titleLabel.text = message.title
            speakerLabel.text = message.speakers.map { $0.name }.joined(separator: ", ")
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            imageView.cancel()
            titleLabel.text = nil
            speakerLabel.text = nil
        }
        
    }
    
}
