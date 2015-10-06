//
//  ColumnToggleCell.swift
//  Ello
//
//  Created by Sean on 10/5/15.
//  Copyright © 2015 Ello. All rights reserved.
//

import Foundation

public class ColumnToggleCell: UICollectionViewCell {
    static let reuseIdentifier = "ColumnToggleCell"

    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!

    weak var columnToggleDelegate: ColumnToggleDelegate?

    @IBAction func gridTapped(sender: UIButton) {
        columnToggleDelegate?.columnToggleTapped(true)
    }

    @IBAction func singleTapped(sender: UIButton) {
        columnToggleDelegate?.columnToggleTapped(false)
    }

}