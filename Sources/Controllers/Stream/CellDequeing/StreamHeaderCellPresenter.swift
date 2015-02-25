//
//  StreamHeaderCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct StreamHeaderCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? StreamHeaderCell {
            if streamCellItem.type == .Header {
                cell.streamKind = streamKind
            }

            cell.setAvatarURL((streamCellItem.jsonable as Authorable).author?.avatarURL)
            cell.timestampLabel.text = NSDate().distanceOfTimeInWords((streamCellItem.jsonable as Authorable).createdAt)
            cell.usernameLabel.text = ((streamCellItem.jsonable as Authorable).author?.atName ?? "@meow")

        }
    }

}