//
//  SpringyScrollView.swift
//  TM
//
//  Created by Amin Amjadi on 7/16/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

class SpringyFlowLayout: UICollectionViewFlowLayout {
    var dynamicAnimator: UIDynamicAnimator?
    
    func setupLayout() {
        minimumInteritemSpacing = 5
        minimumLineSpacing = AppConstants.minimumLineSpacing
        dynamicAnimator = nil
    }
    
    override func prepare() {
        super.prepare()
        
        if dynamicAnimator != nil {
            return
        }
        
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
        
        let contentSize = collectionViewContentSize
        
        if let items = super.layoutAttributesForElements(
            in: CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)) {
            
            for item in items {
                let spring = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
                spring.length = 0
                spring.damping = 0.5
                spring.frequency = 0.8
                dynamicAnimator?.addBehavior(spring)
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return dynamicAnimator?.items(in: rect) as? [UICollectionViewLayoutAttributes] ??
            super.layoutAttributesForElements(in: rect)
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator?.layoutAttributesForCell(at: indexPath as IndexPath) ??
            super.layoutAttributesForItem(at: indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let collectionView = collectionView,
            let dynamicAnimator = dynamicAnimator {
            let delta =  newBounds.origin.y - collectionView.bounds.origin.y
            
            let touchLocation = collectionView.panGestureRecognizer.location(in: collectionView)
            
            for spring in dynamicAnimator.behaviors {
                if let spring = spring as? UIAttachmentBehavior,
                    let item = spring.items.first as? UICollectionViewLayoutAttributes {
                    
                    // Increase the length of the spring based on how far the item is from the touch location
                    // The farther away the item - the more stretch the spring will be
                    let anchorPoint: CGFloat = spring.anchorPoint.y
                    let distanceFromTouch: CGFloat = fabs(anchorPoint - touchLocation.y)
                    let scrollResistance: CGFloat = distanceFromTouch / 500
                    
                    var center = item.center
                    center.y += delta * scrollResistance
                    item.center = center
                    
                    dynamicAnimator.updateItem(usingCurrentState: item)
                }
            }
        }
        
        return false
    }
}
