//
//  String+Extensions.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 01/03/2021.
//

import Foundation

extension String {
    var isTrimmedEmpty: Bool {
        get {
            self.trim().isEmpty
        }
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func isNullOrEmpty(_ string: String?) -> Bool {
        guard let string = string else {
            return true
        }
        return string.isTrimmedEmpty
    }
}
