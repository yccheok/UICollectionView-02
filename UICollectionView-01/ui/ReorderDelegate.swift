//
//  ReorderDelegate.swift
//  UICollectionView-01
//
//  Created by Yan Cheng Cheok on 10/06/2021.
//

import Foundation
import UIKit

protocol ReorderDelegate : AnyObject {
    func began(_ gesture: UILongPressGestureRecognizer)
    func changed(_ gesture: UILongPressGestureRecognizer)
    func ended(_ gesture: UILongPressGestureRecognizer)
    func cancel(_ gesture: UILongPressGestureRecognizer)
}
