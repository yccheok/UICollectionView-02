//
//  PlainNote.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 27/02/2021.
//

import Foundation

struct PlainNote: Codable {
    var title: String
    var body: String
    var pinned: Bool
    let uuid: UUID
    
    enum CodingKeys: String, CodingKey {
        case title
        case body
        case pinned
        case uuid
    }
}

extension PlainNote: Hashable {
    static func == (lhs: PlainNote, rhs: PlainNote) -> Bool {
        if lhs.title != rhs.title {
            return false
        }
        
        if lhs.body != rhs.body {
            return false
        }
        
        // Seems risky by not taking "pinned" into account. But, this is a dirty workaround to make pinned animation
        // work. Apple's diffable data source framework is pretty broken. It is not able to identify same item with
        // different content - https://developer.apple.com/forums/thread/653647
        //if lhs.pinned != rhs.pinned {
        //    return false
        //}
        
        if lhs.uuid != rhs.uuid {
            return false
        }
        
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(body)
        
        // Seems risky by not taking "pinned" into account. But, this is a dirty workaround to make pinned animation
        // work. Apple's diffable data source framework is pretty broken. It is not able to identify same item with
        // different content - https://developer.apple.com/forums/thread/653647
        //hasher.combine(pinned)
        
        hasher.combine(uuid)
    }
}

extension PlainNote {
    init(title: String, body: String, pinned: Bool) {
        self.init(title: title, body: body, pinned: pinned, uuid: UUID())
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        body = try values.decode(String.self, forKey: .body)
        pinned = try values.decode(Bool.self, forKey: .pinned)
        do {
            uuid = try values.decode(UUID.self, forKey: .uuid)
        } catch {
            uuid = UUID()
        }
    }
}
