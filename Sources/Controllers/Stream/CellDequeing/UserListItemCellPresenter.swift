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
            let userlike = streamCellItem.jsonable as! Userlike
            
            cell.relationshipView.hidden = false

            if let currentUser = cell.currentUser {
                cell.relationshipView.hidden = userlike.user.id == currentUser.user.id
            }

            if let avatarURL = userlike.user.avatarURL {
                cell.setAvatarURL(avatarURL)
            }

            cell.relationshipView.buildSmallButtons()
            cell.relationshipView.userId = userlike.user.id
            cell.relationshipView.userAtName = userlike.user.atName
            cell.relationshipView.relationship = userlike.user.relationshipPriority
            cell.usernameLabel.text = userlike.user.atName
        }
    }
}
