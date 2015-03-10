//
//  UserListItemCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct UserListItemCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? UserListItemCell {
            let user = streamCellItem.jsonable as User

            if let avatarURL = user.avatarURL? {
                cell.setAvatarURL(avatarURL)
            }

            cell.relationshipView.userId = user.userId
            cell.relationshipView.userAtName = user.atName
            if let relationship = Relationship(rawValue: user.relationshipPriority) {
                cell.relationshipView.relationship = relationship
            }
            else {
                cell.relationshipView.relationship = Relationship.None
            }
            cell.relationshipView.hidden = user.isCurrentUser
            cell.usernameLabel.text = user.atName
        }
    }
}
