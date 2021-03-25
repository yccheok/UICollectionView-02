//
//  RepositoryUtils.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 25/03/2021.
//

import Foundation
import CoreData

enum RepositoryUtils {
    static func saveContextIfPossible(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
