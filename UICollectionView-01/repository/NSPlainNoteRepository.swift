//
//  PlainNoteRepository.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 25/03/2021.
//

import Foundation
import CoreData

class NSPlainNoteRepository {
    public static let INSTANCE = NSPlainNoteRepository()
    
    private init() {
    }
    
    func updatePinned(_ objectID: NSManagedObjectID, _ pinned: Bool) {
        let coreDataStack = CoreDataStack.INSTANCE
        let backgroundContext = coreDataStack.backgroundContext

        // TODO: Can we optimize the code, to avoid fetching the entire model object?
        backgroundContext.perform {
            let nsPlainNote = try! backgroundContext.existingObject(with: objectID) as! NSPlainNote
            nsPlainNote.pinned = pinned
            RepositoryUtils.saveContextIfPossible(backgroundContext)
        }
    }
    
    func insertAsync(_ plainNote: PlainNote) {
        let coreDataStack = CoreDataStack.INSTANCE
        let backgroundContext = coreDataStack.backgroundContext
        
        backgroundContext.perform {
            let _ = NSPlainNote(context: backgroundContext, plainNote: plainNote)
            RepositoryUtils.saveContextIfPossible(backgroundContext)
        }
    }
    
    func deleteAllAsync() {
        let coreDataStack = CoreDataStack.INSTANCE
        let backgroundContext = coreDataStack.backgroundContext
        
        backgroundContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: NSPlainNote.self))
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            // Asks to return the objectIDs deleted
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let batchDeleteResult = try backgroundContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                let managedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID]
                
                let changes = [NSDeletedObjectsKey : managedObjectIDs]
                
                coreDataStack.mergeChanges(changes)
                
                // Save context is not required.
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
