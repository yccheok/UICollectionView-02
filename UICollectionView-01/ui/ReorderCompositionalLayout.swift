//
//  ReorderCompositionalLayout.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 05/04/2021.
//

import Foundation
import UIKit

class ReorderCompositionalLayout : UICollectionViewCompositionalLayout {
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath as IndexPath, withTargetPosition: position)
        
        attributes.alpha = Constants.DRAG_N_MOVE_ALPHA
        attributes.transform = CGAffineTransform(scaleX: Constants.DRAG_N_MOVE_SCALE, y: Constants.DRAG_N_MOVE_SCALE)

        return attributes
    }
}
