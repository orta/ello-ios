//
//  ColumnToggleCellPresenter.swift
//  Ello
//
//  Created by Sean on 10/5/15.
//  Copyright © 2015 Ello. All rights reserved.
//

public struct ColumnToggleCellPresenter {

    static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? ColumnToggleCell {
            cell.isGridView = streamKind.isGridView
        }
    }
}
