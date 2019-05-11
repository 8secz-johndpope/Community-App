//
//  CarouselFlowLayout.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

final class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    private var lastCollectionViewSize: CGSize = .zero
    private var lastScrollDirection: UICollectionView.ScrollDirection!
    
    required init(itemSize: CGSize, spacing: CGFloat, inset: CGFloat) {
        super.init()
        self.itemSize = itemSize
        self.minimumLineSpacing = spacing
        self.sectionInset = UIEdgeInsets(left: inset, right: inset)
        self.scrollDirection = .horizontal
        self.lastScrollDirection = scrollDirection
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        for attribute in super.layoutAttributesForElements(in: rect) ?? [] {
            let copy = attribute.copy() as! UICollectionViewLayoutAttributes
            copy.frame.origin.y = 0
            attributes.append(copy)
        }
        
        return attributes
    }
    
    override public func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        guard let collectionView = collectionView else { return }
        
        // invalidate layout to center first and last
        let currentCollectionViewSize = collectionView.bounds.size
        if !currentCollectionViewSize.equalTo(lastCollectionViewSize) || lastScrollDirection != scrollDirection {
            let inset: CGFloat
            switch scrollDirection {
            case .horizontal:
                inset = (collectionView.bounds.size.width - itemSize.width) / 2
                collectionView.contentInset = .zero
                collectionView.contentOffset = .zero
            case .vertical:
                inset = (collectionView.bounds.size.height - itemSize.height) / 2
                collectionView.contentInset = UIEdgeInsets(top: inset, bottom: inset)
                collectionView.contentOffset = CGPoint(x: 0, y: -inset)
            @unknown default:
                inset = (collectionView.bounds.size.height - itemSize.height) / 2
                collectionView.contentInset = UIEdgeInsets(top: inset, bottom: inset)
                collectionView.contentOffset = CGPoint(x: 0, y: -inset)
            }
            lastCollectionViewSize = currentCollectionViewSize
            lastScrollDirection = scrollDirection
        }
    }
    
    private func determineProposedRect(collectionView: UICollectionView, proposedContentOffset: CGPoint) -> CGRect {
        let size = collectionView.bounds.size
        let origin: CGPoint
        switch scrollDirection {
        case .horizontal: origin = CGPoint(x: proposedContentOffset.x, y: 0)
        case .vertical:   origin = CGPoint(x: 0, y: proposedContentOffset.y)
        @unknown default: origin = CGPoint(x: 0, y: proposedContentOffset.y)
        }
        return CGRect(origin: origin, size: size)
    }
    
    private func attributesForRect(
        collectionView: UICollectionView,
        layoutAttributes: [UICollectionViewLayoutAttributes],
        proposedContentOffset: CGPoint
        ) -> UICollectionViewLayoutAttributes? {
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedCenterOffset: CGFloat
        
        switch scrollDirection {
        case .horizontal: proposedCenterOffset = proposedContentOffset.x + collectionView.bounds.size.width / 2
        case .vertical:   proposedCenterOffset = proposedContentOffset.y + collectionView.bounds.size.height / 2
        @unknown default: proposedCenterOffset = proposedContentOffset.y + collectionView.bounds.size.height / 2
        }
        
        for attributes: UICollectionViewLayoutAttributes in layoutAttributes {
            guard attributes.representedElementCategory == .cell else { continue }
            guard candidateAttributes != nil else {
                candidateAttributes = attributes
                continue
            }
            
            switch scrollDirection {
            case .horizontal:
                if abs(attributes.center.x - proposedCenterOffset) < abs(candidateAttributes!.center.x - proposedCenterOffset) {
                    candidateAttributes = attributes
                }
            case .vertical:
                if abs(attributes.center.y - proposedCenterOffset) < abs(candidateAttributes!.center.y - proposedCenterOffset) {
                    candidateAttributes = attributes
                }
            @unknown default:
                if abs(attributes.center.y - proposedCenterOffset) < abs(candidateAttributes!.center.y - proposedCenterOffset) {
                    candidateAttributes = attributes
                }
            }
        }
        return candidateAttributes
    }
    
    // swiftlint:disable line_length
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let proposedRect: CGRect = determineProposedRect(collectionView: collectionView, proposedContentOffset: proposedContentOffset)
        
        guard let layoutAttributes = layoutAttributesForElements(in: proposedRect),
            let candidateAttributesForRect = attributesForRect(
                collectionView: collectionView,
                layoutAttributes: layoutAttributes,
                proposedContentOffset: proposedContentOffset
            ) else { return proposedContentOffset }
        
        var newOffset: CGFloat
        let offset: CGFloat
        switch scrollDirection {
        case .horizontal:
            newOffset = candidateAttributesForRect.center.x - collectionView.bounds.size.width / 2
            offset = newOffset - collectionView.contentOffset.x
            
            if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
                let pageWidth = itemSize.width + minimumLineSpacing
                newOffset += velocity.x > 0 ? pageWidth : -pageWidth
            }
            return CGPoint(x: newOffset, y: proposedContentOffset.y)
            
        case .vertical:
            newOffset = candidateAttributesForRect.center.y - collectionView.bounds.size.height / 2
            offset = newOffset - collectionView.contentOffset.y
            
            if (velocity.y < 0 && offset > 0) || (velocity.y > 0 && offset < 0) {
                let pageHeight = itemSize.height + minimumLineSpacing
                newOffset += velocity.y > 0 ? pageHeight : -pageHeight
            }
            return CGPoint(x: proposedContentOffset.x, y: newOffset)
        @unknown default:
            newOffset = candidateAttributesForRect.center.y - collectionView.bounds.size.height / 2
            offset = newOffset - collectionView.contentOffset.y
            
            if (velocity.y < 0 && offset > 0) || (velocity.y > 0 && offset < 0) {
                let pageHeight = itemSize.height + minimumLineSpacing
                newOffset += velocity.y > 0 ? pageHeight : -pageHeight
            }
            return CGPoint(x: proposedContentOffset.x, y: newOffset)
        }
    }
    
    var pageWidth: CGFloat {
        switch scrollDirection {
        case .horizontal: return itemSize.width + minimumLineSpacing
        case .vertical:   return itemSize.height + minimumLineSpacing
        @unknown default: return itemSize.height + minimumLineSpacing
        }
    }
    
    /// Programatically scrolls to a page at a specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the page to scroll to.
    ///   - animated: Whether the scroll should be performed animated.
    func scrollToPage(index: Int, animated: Bool) {
        guard let collectionView = collectionView else { return }
        
        let pageOffset: CGFloat
        let proposedContentOffset: CGPoint
        let shouldAnimate: Bool
        switch scrollDirection {
        case .horizontal:
            pageOffset = CGFloat(index) * pageWidth - collectionView.contentInset.left
            proposedContentOffset = CGPoint(x: pageOffset, y: 0)
            shouldAnimate = abs(collectionView.contentOffset.x - pageOffset) > 1 ? animated : false
        case .vertical:
            pageOffset = CGFloat(index) * pageWidth - collectionView.contentInset.top
            proposedContentOffset = CGPoint(x: 0, y: pageOffset)
            shouldAnimate = abs(collectionView.contentOffset.y - pageOffset) > 1 ? animated : false
        @unknown default:
            pageOffset = CGFloat(index) * pageWidth - collectionView.contentInset.top
            proposedContentOffset = CGPoint(x: 0, y: pageOffset)
            shouldAnimate = abs(collectionView.contentOffset.y - pageOffset) > 1 ? animated : false
        }
        collectionView.setContentOffset(proposedContentOffset, animated: shouldAnimate)
    }
    
    /// Calculates the current centered page.
    var currentCenteredPage: Int? {
        guard let collectionView = collectionView else { return nil }
        let currentCenteredPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.bounds.width/2, y: collectionView.contentOffset.y + collectionView.bounds.height/2)
        let indexPath = collectionView.indexPathForItem(at: currentCenteredPoint)
        return indexPath?.row
    }
    
}

extension CarouselFlowLayout {
    
    static var shelfContent: CarouselFlowLayout  {
        return CarouselFlowLayout(itemSize: .shelfSize, spacing: 10, inset: .padding)
    }
    
    static var seriesContent: CarouselFlowLayout  {
        return CarouselFlowLayout(itemSize: .seriesSize, spacing: 10, inset: .padding)
    }
    
}
