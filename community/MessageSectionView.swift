//
//  MessageSectionView.swift
//  community
//
//  Created by Jonathan Landon on 8/6/18.
//

import UIKit
import Alexandria

final class MessageSectionView: View {
    
    private var messages: [Watermark.Message] = []
    
    private let collectionView = UICollectionView(layout: .horizontal(itemSpacing: .padding/2, lineSpacing: .padding, sectionInset: UIEdgeInsets(left: .padding * 1.5, right: .padding)))
    
    override func setup() {
        super.setup()
        
        collectionView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.constrainHeight(to: 170)
            $0.registerCell(SmallMessageCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.showsHorizontalScrollIndicator = false
            $0.alwaysBounceHorizontal = true
            $0.decelerationRate = UIScrollViewDecelerationRateFast
            $0.backgroundColor = .lightBackground
        }
    }
    
    func configure(messages: [Watermark.Message]) {
        self.messages = messages
        self.collectionView.reloadData()
    }
    
}

extension MessageSectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SmallMessageCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(message: messages[indexPath.row])
        return cell
    }
    
}

extension MessageSectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width * 0.75, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let message = messages.at(indexPath.row) else { return }
        MessageViewController(message: message).show()
    }
    
}
