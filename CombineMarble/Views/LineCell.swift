//
//  LineCell.swift
//  CombineMarble
//
//  Created by Alfian Losari on 02/07/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit

class LineCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let length = min(self.bounds.height, self.bounds.width) - 8.0
        view.layer.cornerRadius = length / 2.0
        viewHeightConstraint.constant = length
    }
    
    func setup() {
        view.layer.cornerRadius = view.frame.width / 2.0
    }
}
