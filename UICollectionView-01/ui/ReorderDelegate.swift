//
//  ReorderDelegate.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 04/04/2021.
//

import Foundation
import UIKit

protocol ReorderDelegate : AnyObject {
    func began(_ gesture: UILongPressGestureRecognizer)
    func changed(_ gesture: UILongPressGestureRecognizer)
    func end(_ gesture: UILongPressGestureRecognizer)
    func cancel(_ gesture: UILongPressGestureRecognizer)
}
