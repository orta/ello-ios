//
//  UserListItemCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct UserListItemCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? UserListItemCell {
            let user = streamCellItem.jsonable as! User
            
            cell.relationshipView.hidden = false

            if let currentUser = cell.currentUser {
                cell.relationshipView.hidden = user.userId == currentUser.userId
            }

            if let avatarURL = user.avatarURL {
                cell.setAvatarURL(avatarURL)
            }

            cell.relationshipView.buildSmallButtons()
            cell.relationshipView.userId = user.userId
            cell.relationshipView.userAtName = user.atName
            cell.relationshipView.relationship = user.relationshipPriority
            cell.usernameLabel.text = user.atName
        }
    }
}
