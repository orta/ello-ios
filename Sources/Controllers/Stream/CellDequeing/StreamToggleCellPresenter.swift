//
//  StreamToggleCellPresenter.swift
//  Ello
//
//  Created by Sean on 3/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct StreamToggleCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? StreamToggleCell {
            if let post = streamCellItem.jsonable as? Post {
                let message = post.collapsed ? cell.closedMessage : cell.openedMessage
                cell.label.setLabelText(message)
            }
        }
    }
}
