//
//  ProfileHeaderCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


public struct ProfileHeaderCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? ProfileHeaderCell {
            let user = streamCellItem.jsonable as! User
            cell.relationshipView.hidden = false

            if let currentUser = cell.currentUser {
                cell.relationshipView.hidden = user.id == currentUser.id
            }
            cell.profileButtonsView.hidden = !cell.relationshipView.hidden

            if let avatarURL = user.avatarURL {
                cell.setAvatarURL(avatarURL)
            }

            cell.relationshipView.buildLargeButtons()
            cell.relationshipView.userId = user.id
            cell.relationshipView.userAtName = user.atName
            cell.relationshipView.relationship = user.relationshipPriority
            cell.usernameLabel.text = user.atName
            cell.nameLabel.text = user.name
            cell.bioWebView.loadHTMLString(StreamTextCellHTML.postHTML(user.formattedShortBio ?? ""), baseURL: NSURL(string: "/"))
            cell.countsTextView.clearText()
            cell.countsTextView.appendTextWithAction("Posts \(user.postsCount ?? 0) / ")
            cell.countsTextView.appendTextWithAction("Following \(user.followingCount ?? 0) / ", link: "following", object: user)
            let followersStr = user.followersCount ?? "0"
            cell.countsTextView.appendTextWithAction("Followers \(followersStr)", link: "followers", object: user)
            println("WTF")
        }
    }
}


