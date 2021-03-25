//
//  Log.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 27/02/2021.
//

import Foundation
import os.log

func error_log(_ error: Error) {
    os_log("%@", log: OSLog.default, type: .error, String(describing: error))
}
