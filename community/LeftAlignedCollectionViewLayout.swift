//
//  LeftAlignedCollectionViewLayout.swift
//  community
//
//  Created by Jonathan Landon on 8/9/18.
//

import UIKit

final class LeftAlignedCollectionViewLayout: UICollectionViewFlowLayout {
    
    override var collectionViewContentSize: CGSize {
        switch scrollDirection {
        case .vertical:   return super.collectionViewContentSize
        case .horizontal:
            if maxX < 10 {
                return super.collectionViewContentSize
            }
            else {
                return CGSize(width: maxX, height: super.collectionViewContentSize.height)
            }
        @unknown default: return super.collectionViewContentSize
        }
    }
    
    var maxX: CGFloat = 0
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        switch scrollDirection {
        case .vertical:
            var attributesToReturn: [UICollectionViewLayoutAttributes] = []
            for attributes in super.layoutAttributesForElements(in: rect) ?? [] {
                guard let attributesCopy = attributes.copy() as? UICollectionViewLayoutAttributes else { continue }

                if attributesCopy.representedElementKind == nil {
                    let indexPath = attributesCopy.indexPath
                    attributesCopy.frame = layoutAttributesForItem(at: indexPath)?.frame ?? .zero
                }

                attributesToReturn.append(attributesCopy)
            }
            return attributesToReturn
        case .horizontal:
            
            maxX = 0
            
            var attributesToReturn: [UICollectionViewLayoutAttributes] = []
            for attributes in super.layoutAttributesForElements(in: rect) ?? [] {
                guard let attributesCopy = attributes.copy() as? UICollectionViewLayoutAttributes else { continue }
                let newAttributes = layoutAttributesForItem(at: attributesCopy.indexPath) ?? attributesCopy
                attributesToReturn.append(newAttributes)
                maxX = max(maxX, newAttributes.frame.maxX + sectionInset.right)
            }
            
            return attributesToReturn
        @unknown default:
            var attributesToReturn: [UICollectionViewLayoutAttributes] = []
            for attributes in super.layoutAttributesForElements(in: rect) ?? [] {
                guard let attributesCopy = attributes.copy() as? UICollectionViewLayoutAttributes else { continue }
                
                if attributesCopy.representedElementKind == nil {
                    let indexPath = attributesCopy.indexPath
                    attributesCopy.frame = layoutAttributesForItem(at: indexPath)?.frame ?? .zero
                }
                
                attributesToReturn.append(attributesCopy)
            }
            return attributesToReturn
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            let collectionView = collectionView,
            collectionView.minimumIndexPath <= indexPath,
            collectionView.maximumIndexPath >= indexPath
        else { return nil }
        
        switch scrollDirection {
        case .vertical:   return layoutVertical(at: indexPath)
        case .horizontal: return layoutHorizontal(at: indexPath)
        @unknown default: return layoutVertical(at: indexPath)
        }
    }
    
    private func layoutHorizontal(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        let sectionInset = evaluatedSectionInsetForItem(at: indexPath.section)

        let previousIndexPathInRow = IndexPath(item: indexPath.item - 2, section: indexPath.section)
        let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)

        if let previousFrame = layoutAttributesForItem(at: previousIndexPathInRow)?.frame {
            currentItemAttributes?.frame.origin.x = previousFrame.maxX + minimumLineSpacing
            return currentItemAttributes
        }
        else if let previousFrame = layoutAttributesForItem(at: previousIndexPath)?.frame {
            currentItemAttributes?.frame.origin.x = previousFrame.minX
            return currentItemAttributes
        }
        else {
            currentItemAttributes?.frame.origin.x = sectionInset.left
            return currentItemAttributes
        }
    }
    
    private func layoutVertical(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        let sectionInset = evaluatedSectionInsetForItem(at: indexPath.section)
        
        let isFirstItemInSection = (indexPath.item == 0)
        let layoutWidth = (collectionView?.width ?? 0) - sectionInset.left - sectionInset.right
        
        if isFirstItemInSection {
            var frame = currentItemAttributes?.frame ?? .zero
            frame.origin.x = sectionInset.left
            currentItemAttributes?.frame = frame
            
            return currentItemAttributes
        }
        
        let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
        let previousFrame = layoutAttributesForItem(at: previousIndexPath)?.frame ?? .zero
        let previousFrameRightPoint = previousFrame.origin.x + previousFrame.width
        let currentFrame = currentItemAttributes?.frame ?? .zero
        let stretchedCurrentFrame = CGRect(x: sectionInset.left, y: currentFrame.origin.y, width: layoutWidth, height: currentFrame.height)
        
        let isFirstItemInRow = !previousFrame.intersects(stretchedCurrentFrame)
        
        if isFirstItemInRow {
            var frame = currentItemAttributes?.frame ?? .zero
            frame.origin.x = sectionInset.left
            currentItemAttributes?.frame = frame
            
            return currentItemAttributes
        }
        
        var frame = currentItemAttributes?.frame ?? .zero
        frame.origin.x = previousFrameRightPoint + evaluatedMinimumInteritemSpacingForSection(at: indexPath.section)
        currentItemAttributes?.frame = frame
        
        return currentItemAttributes
    }
    
    private func evaluatedMinimumInteritemSpacingForSection(at sectionIndex: Int) -> CGFloat {
        if let collectionView = collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
            return delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: sectionIndex) ?? minimumInteritemSpacing
        }
        else {
            return minimumInteritemSpacing
        }
    }
    
    private func evaluatedSectionInsetForItem(at index: Int) -> UIEdgeInsets {
        if let collectionView = collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
            return delegate.collectionView?(collectionView, layout: self, insetForSectionAt: index) ?? sectionInset
        }
        else {
            return sectionInset
        }
    }
}

