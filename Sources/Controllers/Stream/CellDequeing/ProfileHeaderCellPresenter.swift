//
//  ProfileHeaderCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


public struct ProfileHeaderCellPresenter {

    public static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? ProfileHeaderCell {
            let ratio:CGFloat = 16.0/9.0
            let user = streamCellItem.jsonable as! User
            cell.user = user
            cell.currentUser = currentUser
            cell.relationshipControl.hidden = false
            cell.nsfwLabel.hidden = true
            cell.usernameRightConstraint.constant = user.postsAdultContent ? 75.0 : 15.0

            let isCurrentUser: Bool
            if let currentUser = currentUser {
                isCurrentUser = user.id == currentUser.id
            }
            else {
                isCurrentUser = false
            }
            cell.relationshipControl.hidden = isCurrentUser
            cell.profileButtonsView.hidden = !isCurrentUser

            if let cachedImage = TemporaryCache.load(.Avatar)
                where isCurrentUser
            {
                cell.setAvatarImage(cachedImage)
            }

            cell.viewTopConstraint.constant = UIWindow.windowWidth() / ratio
            cell.relationshipControl.userId = user.id
            cell.relationshipControl.userAtName = user.atName
            cell.relationshipControl.relationshipPriority = user.relationshipPriority
            cell.usernameLabel.text = user.atName
            cell.nameLabel.text = user.name
            cell.bioWebView.loadHTMLString(StreamTextCellHTML.postHTML(user.headerHTMLContent), baseURL: NSURL(string: "/"))

            let postCount = user.postsCount?.numberToHuman(showZero: true) ?? "0"
            cell.postsButton.title = NSLocalizedString("Posts", comment: "Posts")
            cell.postsButton.count = postCount
            if let postCount = user.postsCount where postCount > 0 {
                cell.postsButton.enabled = true
            }
            else {
                cell.postsButton.enabled = false
            }

            let followingCount = user.followingCount?.numberToHuman(showZero: true) ?? "0"
            cell.followingButton.title = NSLocalizedString("Following", comment: "Following")
            cell.followingButton.count = followingCount


            let lovesCount = user.lovesCount?.numberToHuman(showZero: true) ?? "0"
            cell.lovesButton.title = NSLocalizedString("Loves", comment: "Loves")
            cell.lovesButton.count = lovesCount

            // The user.followersCount is a String due to a special case where that can return ∞ for the ello user.
            // toInt() returns an optional that will fail when not an Int allowing the ∞ to display for the ello user.
            let fCount: String
            if let followerCount = user.followersCount, followerCountInt = Int(followerCount) {
                fCount = followerCountInt.numberToHuman(showZero: true)
            }
            else {
                fCount = user.followersCount ?? "0"
            }
            cell.followersButton.title = NSLocalizedString("Followers", comment: "Followers")
            cell.followersButton.count = fCount
        }
    }
}
