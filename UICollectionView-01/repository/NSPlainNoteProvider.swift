//
//  PlainNoteProvider.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 26/03/2021.
//

import Foundation
import CoreData

class PlainNoteProvider {
    
    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSPlainNote> = {
        
        // Create a fetch request for the Quake entity sorted by time.
        let fetchRequest = NSFetchRequest<NSPlainNote>(entityName: "NSPlainNote")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "pinned", ascending: true)
        ]
        // Create a fetched results controller and set its fetch request, context, and delegate.
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: CoreDataStack.INSTANCE.persistentContainer.viewContext,
                                                    sectionNameKeyPath: "pinned",
                                                    cacheName: nil
        )
        controller.delegate = fetchedResultsControllerDelegate
        
        // Perform the fetch.
        do {
            try controller.performFetch()
        } catch {
            fatalError("Unresolved error \(error)")
        }
        
        return controller
    }()
    
    
    init(_ fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) {
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    func getPinnedNotes() ->
}
