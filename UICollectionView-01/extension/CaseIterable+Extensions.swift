//
//  CaseIterable+Extensions.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 02/03/2021.
//

import Foundation

extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let allCases = Self.allCases
        let selfIndex = allCases.firstIndex(of: self)!
        let nextIndex = Self.allCases.index(after: selfIndex)
        return allCases[nextIndex == allCases.endIndex ? allCases.startIndex : nextIndex]
    }
}

