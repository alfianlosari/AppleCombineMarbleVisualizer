//
//  SectionController.swift
//  CombineMarble
//
//  Created by Alfian Losari on 02/07/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation
import Combine

let combineDidChangeNotification = Notification.Name(rawValue: "CombineDidChangeNotification")

class SectionController {
    
    fileprivate var _collections = [CombineSectionContainer]()
    var collections: [CombineSectionContainer] {
        return _collections
    }
    
    struct CombineItem: Hashable {
        let text: String?
        
        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    struct CombineCollection: Hashable {
        
        let title: String?
        var items: [CombineItem]
        var container: CombineSectionContainer? = nil
        
        var isCombined = false
        
        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: SectionController.CombineCollection, rhs: SectionController.CombineCollection) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    init() {
        generateCollections()
    }    
}


extension SectionController {
    
    func generateCollections() {
        
        let map = CombineMapSectionContainer()
        let combineLatest = CombineLatestSectionContainer()
        let merge = CombineMergeSectionContainer()
        let zip = CombineZipSectionContainer()
        let filter = CombineFilterSectionContainer()
        
        _collections = [
            zip,
            combineLatest,
            merge,
            map,
            filter
        ]
    }
    
}
