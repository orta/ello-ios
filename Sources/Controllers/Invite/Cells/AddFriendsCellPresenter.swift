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
        case .Invite: return configureInviteFriendsCell(cell, relationshipDelegate: relationshipDelegate, addFriendsCellItem: addFriendsCellItem)
        case .FindContact: return configureInviteFriendsCell(cell, relationshipDelegate: relationshipDelegate, addFriendsCellItem: addFriendsCellItem)
        }
    }

    static func configureFindFriendsCell(
        cell:UITableViewCell,
        relationshipDelegate: RelationshipDelegate?,
        addFriendsCellItem:AddFriendsCellItem)
    {
        if let cell = cell as? FindFriendsCell {
            let user = addFriendsCellItem.user
            cell.nameLabel?.text = user?.atName
            configureCellWithUser(cell, relationshipDelegate: relationshipDelegate, user: user)
        }
    }

    static func configureInviteFriendsCell(
        cell:UITableViewCell,
        relationshipDelegate: RelationshipDelegate?,
        addFriendsCellItem:AddFriendsCellItem)
    {
        if let cell = cell as? InviteFriendsCell {
            cell.nameLabel?.text = addFriendsCellItem.person?.name
        } else if let cell = cell as? FindFriendsCell {
            cell.nameLabel?.text = addFriendsCellItem.person?.name
            let user = addFriendsCellItem.user
            configureCellWithUser(cell, relationshipDelegate: relationshipDelegate, user: user)
        }
    }

    private static func configureCellWithUser(
        cell: FindFriendsCell,
        relationshipDelegate: RelationshipDelegate?,
        user: User?)
    {
        cell.profileImageView?.sd_setImageWithURL(user?.avatarURL)
        cell.relationshipView?.relationshipDelegate = relationshipDelegate
        cell.relationshipView?.buildSmallButtons()
        cell.relationshipView?.userId = user?.userId ?? ""
        cell.relationshipView?.userAtName = user?.atName ?? ""
        cell.relationshipView?.relationship = Relationship(rawValue: user?.relationshipPriority ?? "null")!
        cell.relationshipView?.hidden = user?.isCurrentUser ?? false
    }
}
