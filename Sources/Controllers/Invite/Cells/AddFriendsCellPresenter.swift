//
//  AddFriendsCellPresenter.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/3/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct AddFriendsCellPresenter {
    static func configure(cell: UITableViewCell, addFriendsCellItem: AddFriendsCellItem, relationshipDelegate: RelationshipDelegate?) {
        switch addFriendsCellItem.cellType {
        case .Find: return configureFindFriendsCell(cell, relationshipDelegate: relationshipDelegate, addFriendsCellItem: addFriendsCellItem)
        case .Invite: return configureInviteFriendsCell(cell, addFriendsCellItem: addFriendsCellItem)
        }
    }

    static func configureFindFriendsCell(
        cell:UITableViewCell,
        relationshipDelegate: RelationshipDelegate?,
        addFriendsCellItem:AddFriendsCellItem)
    {
        if let cell = cell as? FindFriendsCell {
            cell.nameLabel?.text = addFriendsCellItem.user?.atName
            cell.profileImageView?.sd_setImageWithURL(addFriendsCellItem.user?.avatarURL)
            cell.relationshipView?.relationshipDelegate = relationshipDelegate
            cell.relationshipView?.buildSmallButtons()
            cell.relationshipView?.userId = addFriendsCellItem.user?.userId ?? ""
            cell.relationshipView?.userAtName = addFriendsCellItem.user?.atName ?? ""
            cell.relationshipView?.relationship = Relationship(rawValue: addFriendsCellItem.user?.relationshipPriority ?? "")!
            cell.relationshipView?.hidden = addFriendsCellItem.user?.isCurrentUser ?? false
        }
    }

    static func configureInviteFriendsCell(
        cell:UITableViewCell,
        addFriendsCellItem:AddFriendsCellItem)
    {
        if let cell = cell as? InviteFriendsCell {
            cell.nameLabel?.text = addFriendsCellItem.name
        }
    }
}
