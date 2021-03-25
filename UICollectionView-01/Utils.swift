//
//  Utils.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 27/02/2021.
//

import Foundation

enum Utils {
    static func loadAndDecodeJSON<D: Decodable>(filename: String) -> D {
        guard
            let url = Bundle.main.url(forResource: filename, withExtension: "json")
        else {
            fatalError()
        }
        do {
            let data = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .useDefaultKeys
            
            let decodedModel = try jsonDecoder.decode(D.self, from: data)
            return decodedModel
        } catch {
            error_log(error)
            return [] as! D
        }
    }
}
