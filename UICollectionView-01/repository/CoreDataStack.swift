//
//  CoreDataStack.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 25/03/2021.
//

import CoreData

class CoreDataStack {
    public static let INSTANCE = CoreDataStack()
    
    private init() {
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "wenote")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // TODO:
        //container.viewContext.automaticallyMergesChangesFromParent = false
        //container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        //container.viewContext.undoManager = nil
        //container.viewContext.shouldDeleteInaccessibleFaults = true
        
        return container
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let backgroundContext = persistentContainer.newBackgroundContext()
        
        // TODO:
        //backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        //backgroundContext.undoManager = nil
        
        return backgroundContext
    }()
}
