//
//  UserListItemCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct UserListItemCellPresenter {

    public static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? UserListItemCell,
            let user = streamCellItem.jsonable as? User
        {
            cell.relationshipControl.hidden = false

            if let currentUser = currentUser {
                cell.relationshipControl.hidden = user.id == currentUser.id
            }

            cell.relationshipControl.showStarredButton = streamKind.showStarredButton
            cell.setUser(user)
        }
    }
}
