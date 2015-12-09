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

    public var isGridView: Bool = false {
        didSet {
            gridButton.selected = isGridView
            listButton.selected = !isGridView
        }
    }
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!

    weak var columnToggleDelegate: ColumnToggleDelegate?

    override public func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.greyF2()
        gridButton.setSVGImages("grid")
        listButton.setSVGImages("list")
        gridButton.backgroundColor = .greyF2()
        listButton.backgroundColor = .greyF2()
    }

    @IBAction func gridTapped(sender: UIButton) {
        isGridView = true
        columnToggleDelegate?.columnToggleTapped(isGridView)
    }

    @IBAction func listTapped(sender: UIButton) {
        isGridView = false
        columnToggleDelegate?.columnToggleTapped(isGridView)
    }

}
