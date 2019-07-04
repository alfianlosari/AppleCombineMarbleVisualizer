//
//  ViewController.swift
//  CombineMarble
//
//  Created by Alfian Losari on 02/07/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {

    var colors: [UIColor] {
        return [
            UIColor.systemRed,
            UIColor.systemBlue,
            UIColor.systemPink,
            UIColor.systemTeal,
            UIColor.systemGreen,
            UIColor.systemIndigo,
            UIColor.systemYellow,
            UIColor.systemPurple,
            UIColor.systemOrange,
            UIColor.systemRed
        ].shuffled()
    }
    
    var isCombining = false
    
    let sectionController = SectionController()
    static let lineDecorationElementKind = "line-decoration-element-kind"
    static let sectionHeaderElementKind = "sectionHeaderElementKind"
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<SectionController.CombineCollection, SectionController.CombineItem>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = " Combine Visualizer"
        
        configureHierarchy()
        configureDataSource()
        configureCombineNotificationUpdateSubscription()
    
        configureNavItem()
        toggleCombine()
    }
    
    private func configureCombineNotificationUpdateSubscription() {
        _ = NotificationCenter.default.publisher(for: combineDidChangeNotification)
            .sink { (note) in
                guard let section = note.object as? SectionController.CombineCollection else {
                    return
                }
                
                let snapshot = self.dataSource.snapshot()
                guard let _ = snapshot.indexOfSection(section) else {
                    return
                }
                let items = section.items
                snapshot.deleteItems(items)
                snapshot.appendItems(items, toSection: section)
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(UINib(nibName: "LineCell", bundle: nil), forCellWithReuseIdentifier: "LineCell")
        collectionView.register(
            UINib(nibName: "SectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: ViewController.sectionHeaderElementKind,
            withReuseIdentifier: "SectionHeaderView")
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionController.CombineCollection, SectionController.CombineItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: SectionController.CombineItem) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "LineCell",
                for: indexPath) as? LineCell else { fatalError("Cannot create new cell") }
            let sections = self.sectionController.collections.flatMap { $0.sections }
            let text = sections[indexPath.section].items[indexPath.item].text
            
            cell.label.text = text
            cell.view.isHidden = text == nil
            cell.view.backgroundColor = self.colors[indexPath.item % 10]
            
            return cell
        }
        
        dataSource.supplementaryViewProvider =  { (
            collectionView: UICollectionView,
            kind: String,
            indexPath: IndexPath) -> UICollectionReusableView? in

            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeaderView",
                for: indexPath) as? SectionHeaderView else { fatalError("Cannot create new supplementary") }

            let sections = self.sectionController.collections.flatMap { $0.sections }
            
            supplementaryView.label.text = sections[indexPath.section].title
            return supplementaryView
        }
        dataSource.apply(getSnapshot(), animatingDifferences: false)
    }
    
    func getSnapshot() -> NSDiffableDataSourceSnapshot<SectionController.CombineCollection, SectionController.CombineItem> {
        let snapshot = NSDiffableDataSourceSnapshot<SectionController.CombineCollection, SectionController.CombineItem>()
        sectionController.collections.forEach {
            for section in $0.sections {
                snapshot.appendSections([section])
                snapshot.appendItems(section.items)
            }
        }
        return snapshot
    }
    
    func performCombine(section: CombineSectionContainer) {
        if !isCombining {
            return
        }
        
        section.send()
        let delay = 1000
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            if section.isCombined {
                let snapshot = self.dataSource.snapshot()
                section.sections.forEach { (section) in
                    snapshot.deleteItems(section.items)
                }
                self.dataSource.apply(snapshot, animatingDifferences: true)
                section.reset()
            }
            self.performCombine(section: section)
        }
    }
    
    func performCombine() {
        self.sectionController.collections.forEach { performCombine(section: $0) }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.125),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(44))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(
            elementKind: ViewController.lineDecorationElementKind)
        sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 44, leading: 0, bottom: 0, trailing: 0)
        section.decorationItems = [sectionBackgroundDecoration]
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: ViewController.sectionHeaderElementKind, alignment: .top)
        
        section.boundarySupplementaryItems = [sectionHeader]

        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.register(
            UINib(nibName: "LineDecorationView", bundle: nil),
            forDecorationViewOfKind: ViewController.lineDecorationElementKind)
        return layout
    }
    
    func configureNavItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: isCombining ? "Pause" : "Combine",
                                                            style: .plain, target: self,
                                                            action: #selector(toggleCombine))
    }
    
    @objc
    func toggleCombine() {
        isCombining.toggle()
        if isCombining {
            performCombine()
        }
        configureNavItem()
    }
}
