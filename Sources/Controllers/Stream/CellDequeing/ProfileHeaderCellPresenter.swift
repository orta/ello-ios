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
            let userlike = streamCellItem.jsonable as! Userlike
            cell.relationshipView.hidden = false

            if let currentUser = cell.currentUser {
                cell.relationshipView.hidden = userlike.user.id == currentUser.user.id
            }
            cell.profileButtonsView.hidden = !cell.relationshipView.hidden

            if let avatarURL = userlike.user.avatarURL {
                cell.setAvatarURL(avatarURL)
            }

            cell.relationshipView.buildLargeButtons()
            cell.relationshipView.userId = userlike.user.id
            cell.relationshipView.userAtName = userlike.user.atName
            cell.relationshipView.relationship = userlike.user.relationshipPriority
            cell.usernameLabel.text = userlike.user.atName
            cell.nameLabel.text = userlike.user.name
            cell.bioWebView.loadHTMLString(StreamTextCellHTML.postHTML(userlike.user.formattedShortBio!), baseURL: NSURL(string: "/"))

            cell.countsTextView.clearText()
            cell.countsTextView.appendTextWithAction("Posts \(userlike.user.postsCount ?? 0) / ")
            cell.countsTextView.appendTextWithAction("Following \(userlike.user.followingCount ?? 0) / ", link: "following", object: userlike.user)
            cell.countsTextView.appendTextWithAction("Followers \(userlike.user.followersCount!)", link: "followers", object: userlike.user)
        }
    }
}


