//
//  ViewController.swift
//  UICollectionView-01
//
//  Created by Cheok Yan Cheng on 27/02/2021.
//

import UIKit
import CoreData

final class DebugDiffableDataSourceReference<SectionIdentifier, ItemIdentifier>: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> where SectionIdentifier: Hashable, ItemIdentifier: Hashable {

    @objc func _collectionView(_ collectionView: UICollectionView, willPerformUpdates updates: [UICollectionViewUpdateItem]) {
        print("DDS updates: \(updates)")
    }
}

class ViewController: UIViewController {
    
    typealias DataSource = DebugDiffableDataSourceReference<Int, NSManagedObjectID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
    
    private static let padding = CGFloat(8.0)
    private static let minListHeight = CGFloat(44.0)
    
    private static let NOTE_CELL = "NOTE_CELL"
    private static let NOTE_HEADER = "NOTE_HEADER"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var layout = Layout.grid
    
    var dataSource: DataSource?
    
    var nsPlainNoteProvider: NSPlainNoteProvider!
    
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
        setupDataSource()
        
        setupNSPlainNoteProvider()
    }

    private func setupCollectionView() {
        let noteCellNib = NoteCell.getUINib()
        collectionView.register(noteCellNib, forCellWithReuseIdentifier: ViewController.NOTE_CELL)
        
        let noteHeaderNib = NoteHeader.getUINib()
        collectionView.register(noteHeaderNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ViewController.NOTE_HEADER)
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
    
    private func setupDataSource() {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, objectID) -> UICollectionViewCell? in
                
                guard let self = self else { return nil }
                
                guard let noteCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ViewController.NOTE_CELL,
                    for: indexPath) as? NoteCell else {
                    return nil
                }
                
                //guard let nsPlainNote = try? CoreDataStack.INSTANCE.persistentContainer.viewContext.existingObject(with: objectID) as? NSPlainNote else { return nil }
                guard let nsPlainNote = self.nsPlainNoteProvider.getNSPlainNote(indexPath) else { return nil }

                // TODO: Conversion required?
                noteCell.setup(nsPlainNote.toPlainNote())
                
                noteCell.updateLayout(self.layout)
                
                
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
        )
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) ->
            UICollectionReusableView? in
            
            guard let self = self else { return nil }
            
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            guard let noteHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ViewController.NOTE_HEADER,
                for: indexPath) as? NoteHeader else {
                return nil
            }
            
            let noteSection = self.nsPlainNoteProvider.getNoteSection(indexPath.section)

            if let noteSection = noteSection {
                noteHeader.setup(noteSection)
            }

            if (self.nsPlainNoteProvider.getPinnedNSPlainNotes().isEmpty) {
                noteHeader.hide()
            } else {
                noteHeader.show()
            }
            
            return noteHeader
        }
        
        self.dataSource = dataSource
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
    func controller(_ fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshotReference: NSDiffableDataSourceSnapshotReference) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let dataSource = self.dataSource else {
                return
            }
            
            var snapshot = snapshotReference as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

            dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
                guard let self = self else { return }
                
                self.collectionView.reloadData()
            }
        }
    }
}
