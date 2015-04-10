//
//  AddFriendsCellPresenter.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/3/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct AddFriendsCellPresenter {

    public static func configure(cell: UITableViewCell, addFriendsCellItem: AddFriendsCellItem, relationshipDelegate: RelationshipDelegate?, inviteCache: InviteCache) {
        switch addFriendsCellItem.cellType {
        case .Find: return configureFindFriendsCell(cell, relationshipDelegate: relationshipDelegate, addFriendsCellItem: addFriendsCellItem)
        case .Invite: return configureInviteFriendsCell(cell, relationshipDelegate: relationshipDelegate, addFriendsCellItem: addFriendsCellItem, inviteCache: inviteCache)
        case .FindContact: return configureInviteFriendsCell(cell, relationshipDelegate: relationshipDelegate, addFriendsCellItem: addFriendsCellItem, inviteCache: inviteCache)
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
        addFriendsCellItem:AddFriendsCellItem,
        inviteCache: InviteCache)
    {
        if let cell = cell as? InviteFriendsCell {
            cell.nameLabel?.text = addFriendsCellItem.person?.name
            let hasInvited = addFriendsCellItem.person.map { inviteCache.has($0.identifier) } ?? false
            hasInvited ? configureCellAfterInvited(cell) : configureCellBeforeInvited(cell)
        } else if let cell = cell as? FindFriendsCell {
            cell.nameLabel?.text = addFriendsCellItem.person?.name
            let user = addFriendsCellItem.user
            configureCellWithUser(cell, relationshipDelegate: relationshipDelegate, user: user)
        }
    }

    private static func configureCellAfterInvited(cell: InviteFriendsCell) {
        cell.inviteButton?.backgroundColor = UIColor.greyA()
        cell.inviteButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cell.inviteButton?.setTitle("Resend", forState: .Normal)
    }

    private static func configureCellBeforeInvited(cell: InviteFriendsCell) {
        cell.inviteButton?.backgroundColor = UIColor.whiteColor()
        cell.inviteButton?.setTitleColor(UIColor.greyA(), forState: .Normal)
        cell.inviteButton?.setTitle("Invite", forState: .Normal)
    }

    private static func configureCellWithUser(
        cell: FindFriendsCell,
        relationshipDelegate: RelationshipDelegate?,
        user: User?)
    {
        cell.profileImageView?.sd_setImageWithURL(user?.avatarURL)
        cell.relationshipView?.relationshipDelegate = relationshipDelegate
        cell.relationshipView?.buildSmallButtons()
        cell.relationshipView?.userId = user?.id ?? ""
        cell.relationshipView?.userAtName = user?.atName ?? ""
        cell.relationshipView?.relationship = user?.relationshipPriority ?? .Null
        cell.relationshipView?.hidden = user?.isCurrentUser ?? false
    }
}
