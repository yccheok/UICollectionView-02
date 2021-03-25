//
//  UIWindow+Extensions.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 02/03/2021.
//

import Foundation
import UIKit

extension UIWindow {
    static var isPortrait: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isPortrait ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isPortrait
        }
    }
    
    static var isLandscape: Bool {
        !isPortrait
    }
}
