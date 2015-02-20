//
//  ProfileHeaderCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


struct ProfileHeaderCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? ProfileHeaderCell {
            let user = streamCellItem.jsonable as User

            if let avatarURL = user.avatarURL? {
                cell.setAvatarURL(avatarURL)
            }

            cell.usernameLabel.text = user.atName
            cell.nameLabel.text = user.name
        }
    }
}


