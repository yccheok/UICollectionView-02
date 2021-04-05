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
        // Having "pinned" as propertiesToFetch is important to ensure we are receiving "move" instead of "update"
        // during pinned/ unpinned.
        fetchRequest.propertiesToFetch = ["pinned"]
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "pinned", ascending: false),
            NSSortDescriptor(key: "order", ascending: true)
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
    
    func getNSPlainNotes(_ sectionIdentifier: String) -> [NSPlainNote] {
        guard let sections = self.fetchedResultsController.sections else { return [] }
        for section in sections {
            if section.name == sectionIdentifier {
                if let nsPlainNotes = section.objects as? [NSPlainNote] {
                    return nsPlainNotes
                } else {
                    return []
                }
            }
        }
        return []
    }
    
    func getPinnedNSPlainNotes() -> [NSPlainNote] {
        return getNSPlainNotes("1")
    }
    
    func getNormalNSPlainNotes() -> [NSPlainNote] {
        return getNSPlainNotes("0")
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
