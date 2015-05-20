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
            let ratio:CGFloat = 16.0/9.0
            let user = streamCellItem.jsonable as! User
            cell.relationshipControl.hidden = false

            if let currentUser = cell.currentUser {
                cell.relationshipControl.hidden = user.id == currentUser.id
            }
            cell.profileButtonsView.hidden = !cell.relationshipControl.hidden

            if let avatarURL = user.avatarURL {
                cell.setAvatarURL(avatarURL)
            }
            cell.viewTopConstraint.constant = UIScreen.screenWidth() / ratio
            cell.relationshipControl.userId = user.id
            cell.relationshipControl.userAtName = user.atName
            cell.relationshipControl.relationship = user.relationshipPriority
            cell.usernameLabel.text = user.atName
            cell.nameLabel.text = user.name
            cell.bioWebView.loadHTMLString(StreamTextCellHTML.postHTML(user.formattedShortBio ?? ""), baseURL: NSURL(string: "/"))
            cell.countsTextView.clearText()

            let extraAttrs = [NSForegroundColorAttributeName: UIColor.blackColor()]

            cell.countsTextView.appendTextWithAction(NSLocalizedString("Posts", comment: "posts"))
            let postCount = user.postsCount?.numberToHuman() ?? "0"
            cell.countsTextView.appendTextWithAction(" \(postCount) ", extraAttrs: extraAttrs)

            cell.countsTextView.appendTextWithAction(NSLocalizedString("Following", comment: "following"), link: "following", object: user)
            let followingCount = user.followingCount?.numberToHuman() ?? "0"
            cell.countsTextView.appendTextWithAction(" \(followingCount) ", link: "following", object: user, extraAttrs: extraAttrs)

            // The user.followersCount is a String due to a special case where that can return ∞ for the ello user. 
            // toInt() returns an optional that will fail when not an Int allowing the ∞ to display for the ello user.
            let fCount: String
            if let followerCountInt = user.followersCount?.toInt() {
                fCount = followerCountInt.numberToHuman()
            }
            else {
                fCount = user.followersCount ?? "0"
            }
            cell.countsTextView.appendTextWithAction(NSLocalizedString("Followers", comment: "followers"), link: "followers", object: user)
            cell.countsTextView.appendTextWithAction(" \(fCount) ", link: "followers", object: user, extraAttrs: extraAttrs)
        }
    }
}
