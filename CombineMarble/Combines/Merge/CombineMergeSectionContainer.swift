//
//  CombineMergeSectionContainer.swift
//  CombineMarble
//
//  Created by Alfian Losari on 04/07/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation
import Combine

class CombineMergeSectionContainer: CombineSectionContainer {
    
    var numbers1 = PassthroughSubject<String?, Error>()
    var numbers2 = PassthroughSubject<String?, Error>()
    
    var sections: [SectionController.CombineCollection] {
        return [
            firstLine,
            secondLine,
            combinedLine
        ]
    }
    
    private lazy var firstLine: SectionController.CombineCollection = {
        var first = SectionController.CombineCollection(title: "Merge", items: [])
        first.container = self
        return first
    }()
    
    private lazy var secondLine: SectionController.CombineCollection  = {
        var second = SectionController.CombineCollection(title: " ", items: [])
        second.container = self
        return second
    }()
    
    private lazy var combinedLine: SectionController.CombineCollection  = {
        var second = SectionController.CombineCollection(title: " ", items: [])
        second.container = self
        return second
    }()
    
    private var randomValues: [String] {
        return [
            "1",
            "D",
            "3",
            "7",
            "B",
            "C",
            "9",
            "F"
            ].shuffled()
        
    }
    
    private lazy var sendValues: [String] = {
        return self.randomValues
    }()
    
    var isCombined = false
    
    init() {
        setupSubscription()
    }
    
    private func setupSubscription() {
        _ = numbers1.sink(receiveValue: { (value) in
            self.firstLine.items.append(SectionController.CombineItem(text: value))
            self.secondLine.items.append(SectionController.CombineItem(text: nil))
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.firstLine)
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.secondLine)
        })
        
        _ = numbers2.sink(receiveValue: { (value) in
            self.firstLine.items.append(SectionController.CombineItem(text: nil))
            self.secondLine.items.append(SectionController.CombineItem(text: value))
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.firstLine)
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.secondLine)
        })
        
        _ = numbers1.merge(with: numbers2)
            .sink(receiveValue: { (merged) in
                self.combinedLine.items.append(SectionController.CombineItem(text: merged))
                NotificationCenter.default.post(name: combineDidChangeNotification, object: self.combinedLine)
            })
    }
    
    func reset() {
        sendValues = self.randomValues
        
        self.isCombined = false
        
        self.firstLine.items.removeAll()
        self.secondLine.items.removeAll()
        self.combinedLine.items.removeAll()
        
        numbers1 = PassthroughSubject<String?, Error>()
        numbers2 = PassthroughSubject<String?, Error>()
        
        setupSubscription()
    }
    
    func send() {
        guard let value = sendValues.popLast() else {
            self.isCombined = true
            return
        }
        
        if let _ = Int(value) {
            numbers1.send(value)
            
        } else {
            numbers2.send(value)
        }        
    }
}
