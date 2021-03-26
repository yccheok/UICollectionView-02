//
//  NSPlainNote+CoreDataClass.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 25/03/2021.
//
//

import Foundation
import CoreData

@objc(NSPlainNote)
public class NSPlainNote: NSManagedObject {
    convenience init(context: NSManagedObjectContext, plainNote: PlainNote) {
        self.init(context: context)
        
        self.title = plainNote.title
        self.body = plainNote.body
        self.pinned = plainNote.pinned
        self.uuid = plainNote.uuid
    }
    
    func toPlainNote() -> PlainNote {
        return PlainNote(title: title!, body: body!, pinned: pinned, uuid: uuid)
    }
}
