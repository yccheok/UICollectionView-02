//
//  PlainNoteRepository.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 25/03/2021.
//

import Foundation

class PlainNoteRepository {
    public static let INSTANCE = PlainNoteRepository()
    
    private init() {
    }
    
    func insertAsync(_ plainNote: PlainNote) {
        let coreDataStack = CoreDataStack.INSTANCE
        let backgroundContext = coreDataStack.backgroundContext
        
        backgroundContext.perform {
            let _ = NSPlainNote(context: backgroundContext, plainNote: plainNote)
            RepositoryUtils.saveContextIfPossible(backgroundContext)
        }
    }
}
