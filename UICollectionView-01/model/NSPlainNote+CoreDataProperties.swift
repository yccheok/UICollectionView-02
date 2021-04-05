//
//  NSPlainNote+CoreDataProperties.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 04/04/2021.
//
//

import Foundation
import CoreData


extension NSPlainNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NSPlainNote> {
        return NSFetchRequest<NSPlainNote>(entityName: "NSPlainNote")
    }

    @NSManaged public var body: String?
    @NSManaged public var title: String?
    @NSManaged public var pinned: Bool
    @NSManaged public var order: Int64
    @NSManaged public var uuid: UUID
}

extension NSPlainNote : Identifiable {

}
