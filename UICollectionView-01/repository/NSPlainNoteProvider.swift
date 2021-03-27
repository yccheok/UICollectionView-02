//
//  PlainNoteProvider.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 26/03/2021.
//

import Foundation
import CoreData

class NSPlainNoteProvider {
    
    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSPlainNote> = {
        
        // Create a fetch request for the Quake entity sorted by time.
        let fetchRequest = NSFetchRequest<NSPlainNote>(entityName: "NSPlainNote")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "pinned", ascending: false)
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
    
    func getPinnedNSPlainNotes() -> [NSPlainNote] {
        guard let sections = self.fetchedResultsController.sections else { return [] }
        for section in sections {
            if section.name == "1" {
                if let nsPlainNotes = section.objects as? [NSPlainNote] {
                    return nsPlainNotes
                } else {
                    return []
                }
            }
        }
        return []
    }
    
    func getNormalNSPlainNotes() -> [NSPlainNote] {
        guard let sections = self.fetchedResultsController.sections else { return [] }
        for section in sections {
            if section.name == "0" {
                if let nsPlainNotes = section.objects as? [NSPlainNote] {
                    return nsPlainNotes
                } else {
                    return []
                }
            }
        }
        return []
    }
    
    func getNSPlainNote(_ indexPath: IndexPath) -> NSPlainNote? {
        guard let sections = self.fetchedResultsController.sections else { return nil }
        return sections[indexPath.section].objects?[indexPath.item] as? NSPlainNote
    }
    
    func getNoteSection(_ sectionIndex: Int) -> NoteSection? {
        guard let sections = self.fetchedResultsController.sections else { return nil }
        if (sections[sectionIndex].name == "0") {
            return NoteSection.normal
        } else {
            return NoteSection.pin
        }
    }
    
    func numberOfSections() -> Int {
        guard let sections = self.fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
}
