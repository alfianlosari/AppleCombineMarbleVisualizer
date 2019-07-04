//
//  CombineMapSectionContainer.swift
//  CombineMarble
//
//  Created by Alfian Losari on 04/07/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Combine
import Foundation

class CombineMapSectionContainer: CombineSectionContainer {
    
    var isCombined: Bool = false
    let numbers = PassthroughSubject<Int, Error>()
    
    var sections: [SectionController.CombineCollection] {
        return [
            firstLine,
            mappedLine
        ]
    }
    
    private lazy var firstLine: SectionController.CombineCollection = {
        var first = SectionController.CombineCollection(title: "Map", items: [])
        first.container = self
        
        return first
    }()
    
    private lazy var mappedLine: SectionController.CombineCollection  = {
        var second = SectionController.CombineCollection(title: " ", items: [])
        second.container = self
        return second
    }()
    
    
    private lazy var emojis: [String] = {
        return self.randomEmojis
    }()
    
    private var randomValues: [Int] {
        return Array(0..<8).shuffled()
    }
    
    private lazy var sendValues: [Int] = {
        return self.randomValues
    }()
    
    private lazy var randomEmojis: [String] = {
        return ["🥰", "😍", "😜", "🤪", "😉", "😄", "😀", "🤓"].shuffled()
    }()
    
    init() {
        _ = numbers.sink(receiveValue: { (value) in
            self.firstLine.items.append(SectionController.CombineItem(text: "\(value)"))
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.firstLine)
        })
        
        _ = numbers.map {
            self.emojis[$0]
        }.sink(receiveValue: { (emoji) in
            self.mappedLine.items.append(SectionController.CombineItem(text: "\(emoji)"))
            NotificationCenter.default.post(name: combineDidChangeNotification, object: self.mappedLine)
        })
    }
    
    func send() {
        guard let value = sendValues.popLast() else {
            self.isCombined = true
            return
        }
        numbers.send(value)
    }
    
    func reset() {
        sendValues = self.randomValues
        emojis = self.randomEmojis
        self.isCombined = false
        self.firstLine.items.removeAll()
        self.mappedLine.items.removeAll()
    }
}
