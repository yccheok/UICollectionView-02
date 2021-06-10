//
//  ViewController.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 27/02/2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    private static let padding = CGFloat(8.0)
    private static let minListHeight = CGFloat(44.0)
    
    private static let NOTE_CELL = "NOTE_CELL"
    private static let NOTE_HEADER = "NOTE_HEADER"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var layout = Layout.grid
    
    var movingIndexPath: IndexPath?
    
    var touchedDx: CGFloat = 0.0
    var touchedDy: CGFloat = 0.0
    
    var nsPlainNoteProvider: NSPlainNoteProvider!
    
    var blockOperations: [BlockOperation] = []

    var ignoreUpdate = false
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.reloadData()
    }
    
    @IBAction func reset(_ sender: Any) {
        deletePlainNotesFromCoreData()
        savePlainNotesToCoreData()
    }
    
    @IBAction func layoutButtonPressed(_ sender: Any) {
        layout = layout.next()
        
        setupLayout()
        
        // We call reloadData instead of collectionView.collectionViewLayout.invalidateLayout(). We need to ensure
        // updateLayout is executed within setupDataSource.
        collectionView.reloadData()
    }
    
    @IBAction func pinButtonPressed(_ sender: Any) {
        let normalNSPlainNotes = nsPlainNoteProvider.getNormalNSPlainNotes()
        if normalNSPlainNotes.isEmpty {
            return
        }
        
        let sourceIndex = Int.random(in: 0..<normalNSPlainNotes.count)
        let normalNSPlainNote = normalNSPlainNotes[sourceIndex]
        let objectID = normalNSPlainNote.objectID
        NSPlainNoteRepository.INSTANCE.updatePinned(objectID, true)
    }
    
    @IBAction func unpinButtonPressed(_ sender: Any) {
        let pinnedNSPlainNotes = nsPlainNoteProvider.getPinnedNSPlainNotes()
        if pinnedNSPlainNotes.isEmpty {
            return
        }
        
        let sourceIndex = Int.random(in: 0..<pinnedNSPlainNotes.count)
        let pinnedNSPlainNote = pinnedNSPlainNotes[sourceIndex]
        let objectID = pinnedNSPlainNote.objectID
        NSPlainNoteRepository.INSTANCE.updatePinned(objectID, false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupLayout()
        
        setupNSPlainNoteProvider()
    }

    private func setupCollectionView() {
        let noteCellNib = NoteCell.getUINib()
        collectionView.register(noteCellNib, forCellWithReuseIdentifier: ViewController.NOTE_CELL)
        
        let noteHeaderNib = NoteHeader.getUINib()
        collectionView.register(noteHeaderNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ViewController.NOTE_HEADER)
        
        collectionView.dataSource = self
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        collectionView?.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.began(gesture)
        case .changed:
            self.changed(gesture)
        case .ended:
            self.ended(gesture)
        default:
            self.cancel(gesture)
        }
    }
    
    private func setupLayout() {
        switch layout {
        case .grid:
            return setupGridLayout()
        case .compactGrid:
            return setupCompactGridLayout()
        case .list:
            return setupListLayout()
        case .compactList:
            return setupCompactListLayout()
        }
    }
    
    private func setupGridLayout(_ itemCountPerRow: Int) {
        let fraction: CGFloat = 1 / CGFloat(itemCountPerRow)
        
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(fraction))
        //let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: itemCountPerRow)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        // Horizontal spacing between cards within same group.
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        // Spacing for collection view's leading & trailing & bottom. For top, it is the spacing between header and item
        section.contentInsets = NSDirectionalEdgeInsets(
            top: ViewController.padding * 2,
            leading: ViewController.padding,
            bottom: ViewController.padding * 2,
            trailing: ViewController.padding
        )
        // Vertical spacing between cards within different group.
        section.interGroupSpacing = ViewController.padding
        
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        let compositionalLayout = UICollectionViewCompositionalLayout(section: section)

        // Switch the layout to UICollectionViewCompositionalLayout
        collectionView.collectionViewLayout = compositionalLayout
    }
    
    private func setupGridLayout() {
        if UIWindow.isPortrait {
            setupGridLayout(2)
        } else {
            setupGridLayout(3)
        }
    }
    
    private func setupCompactGridLayout() {
        if UIWindow.isPortrait {
            setupGridLayout(3)
        } else {
            setupGridLayout(4)
        }
    }
    
    private func setupListLayout() {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        // Group
        let groupSize = itemSize
        //let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        group.interItemSpacing = .fixed(0)
        
        let section = NSCollectionLayoutSection(group: group)
        // Spacing for collection view's leading & trailing & bottom. For top, it is the spacing between header and item
        section.contentInsets = NSDirectionalEdgeInsets(
            top: ViewController.padding * 2,
            leading: ViewController.padding,
            bottom: ViewController.padding * 2,
            trailing: ViewController.padding
        )
        // Vertical spacing between cards within different group.
        section.interGroupSpacing = ViewController.padding
        
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        let compositionalLayout = UICollectionViewCompositionalLayout(section: section)

        // Switch the layout to UICollectionViewCompositionalLayout
        collectionView.collectionViewLayout = compositionalLayout
    }
    
    private func setupCompactListLayout() {
        setupListLayout()
    }
    
    private func setupNSPlainNoteProvider() {
        self.nsPlainNoteProvider = NSPlainNoteProvider(self)
        _ = self.nsPlainNoteProvider.fetchedResultsController
    }
    
    private func savePlainNotesToCoreData() {
        let pinnedNotes: [PlainNote] = Utils.loadAndDecodeJSON(filename: "pinned_plain_note")
        let normalNotes: [PlainNote] = Utils.loadAndDecodeJSON(filename: "normal_plain_note")
        
        for pinnedNote in pinnedNotes {
            NSPlainNoteRepository.INSTANCE.insertAsync(pinnedNote)
        }
        
        for normalNote in normalNotes {
            NSPlainNoteRepository.INSTANCE.insertAsync(normalNote)
        }
    }
    
    private func deletePlainNotesFromCoreData() {
        NSPlainNoteRepository.INSTANCE.deleteAllAsync()
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Object: \(newIndexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.insertItems(at: [newIndexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Object: \(indexPath)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self, let indexPath = indexPath {
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.move {
            print("Move Object: \(indexPath) to \(newIndexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self, let newIndexPath = newIndexPath, let indexPath = indexPath {
                        self.collectionView.moveItem(at: indexPath, to: newIndexPath)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Object: \(indexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.deleteItems(at: [indexPath!])
                    }
                })
            )
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.insertSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.reloadSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.deleteSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if ignoreUpdate {
            ignoreUpdate = false
            self.blockOperations.removeAll(keepingCapacity: false)
            self.collectionView.reloadData()
            return
        }
        
        collectionView!.performBatchUpdates({ [weak self] () -> Void  in
            guard let self = self else { return }
            
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { [weak self] (finished) -> Void in
            
            guard let self = self else { return }
            
            self.blockOperations.removeAll(keepingCapacity: false)

            self.collectionView.reloadData()
            
            if self.collectionView.numberOfSections > 0 {
                // https://stackoverflow.com/a/46751421/72437
                self.collectionView.numberOfItems(inSection: 0)
            }
        })
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return nsPlainNoteProvider.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader) {
            let noteHeader = configureHeader(indexPath)

            return noteHeader
        } else {
            fatalError()
        }
    }
    
    private func configureHeader(_ indexPath: IndexPath) -> NoteHeader {
        guard let noteHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ViewController.NOTE_HEADER, for: indexPath) as? NoteHeader else {
            fatalError()
        }
        
        let section = indexPath.section
        
        if let noteSection = self.nsPlainNoteProvider.getNoteSection(section) {
            noteHeader.setup(noteSection)
        }

        if (self.nsPlainNoteProvider.getPinnedNSPlainNotes().isEmpty) {
            noteHeader.hide()
        } else {
            noteHeader.show()
        }

        return noteHeader
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nsPlainNoteProvider.numberOfItemsInSection(section)
    }
    
    private func configureCell(_ nsPlainNote: NSPlainNote, _ indexPath: IndexPath) -> NoteCell {
        guard let noteCell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.NOTE_CELL, for: indexPath) as? NoteCell else {
            fatalError()
        }
        
        // TODO: Conversion required?
        noteCell.setup(nsPlainNote.toPlainNote())
        
        noteCell.updateLayout(self.layout)
        
        return noteCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let nsPlainNote = self.nsPlainNoteProvider.getNSPlainNote(indexPath) else {
            fatalError()
        }

        let noteCell = configureCell(nsPlainNote, indexPath)
        
        //
        // DEBUG
        //
        let noteSection = self.nsPlainNoteProvider.getNoteSection(indexPath.section)
        if noteSection == .normal && nsPlainNote.pinned {
            print("Oh no! This \(indexPath.item)th note should be in Pinned section")
            print("title-> \(nsPlainNote.title)")
        } else if noteSection == .pin && !nsPlainNote.pinned {
            print("Oh no! This \(indexPath.item)th note should be in Normal section")
            print("title-> \(nsPlainNote.title)")
        }
        //
        // DEBUG
        //
        
        return noteCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        // Switch the Items in the DataSource
        
        let minItem = min(sourceIndexPath.item, destinationIndexPath.item)
        let maxItem = max(sourceIndexPath.item, destinationIndexPath.item)
        let nsPlainNotes = nsPlainNoteProvider.getNSPlainNotes(sourceIndexPath.section)
        
        let sourcePlainNote = nsPlainNotes[sourceIndexPath.item]
        
        let order0 = nsPlainNotes[minItem].order
        let order1 = nsPlainNotes[maxItem].order
        var minOrder = min(order0, order1)
        
        var updates:[(objectID: NSManagedObjectID, order: Int64)] = []
        
        if (sourceIndexPath.item < destinationIndexPath.item) {
            for item in minItem+1...maxItem {
                let nsPlainNote = nsPlainNotes[item]
                if minOrder != nsPlainNote.order {
                    updates.append((nsPlainNote.objectID, minOrder))
                }
                minOrder = minOrder + 1
            }
            if minOrder != sourcePlainNote.order {
                updates.append((sourcePlainNote.objectID, minOrder))
            }
        } else {
            if minOrder != sourcePlainNote.order {
                updates.append((sourcePlainNote.objectID, minOrder))
            }
            for item in minItem...maxItem-1 {
                minOrder = minOrder + 1
                let nsPlainNote = nsPlainNotes[item]
                if minOrder != nsPlainNote.order {
                    updates.append((nsPlainNote.objectID, minOrder))
                }
            }
        }
        
        ignoreUpdate = true
        
        NSPlainNoteRepository.INSTANCE.updateOrders(updates)
    }
}

extension ViewController : ReorderDelegate {
    func began(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self.collectionView)
        
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else {
            return
        }
        
        guard let noteCell = collectionView.cellForItem(at: indexPath as IndexPath) as? NoteCell else {
            return
        }
        
        let noteCellLocation = gesture.location(in: noteCell)
        touchedDx = noteCellLocation.x - noteCell.frame.width/2
        touchedDy = noteCellLocation.y - noteCell.frame.height/2
        
        self.movingIndexPath = indexPath
        
        collectionView.beginInteractiveMovementForItem(at: indexPath)

        noteCell.liftUp()
    }
    
    func changed(_ gesture: UILongPressGestureRecognizer) {
        var location = gesture.location(in: collectionView)
        
        // Lock down the x position
        // https://stackoverflow.com/questions/40116282/preventing-moving-uicollectionviewcell-by-its-center-when-dragging
        location.x = location.x - touchedDx
        location.y = location.y - touchedDy
        
        collectionView.updateInteractiveMovementTargetPosition(location)
    }
    
    func ended(_ gesture: UILongPressGestureRecognizer) {
        UIView.animate(withDuration: 0, animations: { [weak self] in
            self?.collectionView.endInteractiveMovement()
        })
        
        if let movingIndexPath = self.movingIndexPath, let noteCell = collectionView.cellForItem(at: movingIndexPath as IndexPath) as? NoteCell {
            noteCell.liftDown()
        }
        
        self.movingIndexPath = nil

        touchedDx = 0
        touchedDy = 0
    }
    
    func cancel(_ gesture: UILongPressGestureRecognizer) {
        collectionView.endInteractiveMovement()
        
        if let movingIndexPath = self.movingIndexPath, let noteCell = collectionView.cellForItem(at: movingIndexPath as IndexPath) as? NoteCell {
            noteCell.liftDown()
        }
        
        self.movingIndexPath = nil
        
        touchedDx = 0
        touchedDy = 0
    }
    
}
