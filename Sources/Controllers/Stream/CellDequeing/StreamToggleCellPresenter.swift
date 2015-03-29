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
            let user = streamCellItem.jsonable as! Post
            cell.textView.clearText()
            cell.textView.appendTextWithAction("NSFW: ")
            cell.textView.appendTextWithAction("Tap to Open", link: "open", object: nil)
        }
    }
}