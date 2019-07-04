//
//  CombineSectionContainer.swift
//  CombineMarble
//
//  Created by Alfian Losari on 04/07/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Combine

protocol CombineSectionContainer {
    var sections: [SectionController.CombineCollection] { get }
    var isCombined: Bool { get }
    func reset()
    func send()
}
