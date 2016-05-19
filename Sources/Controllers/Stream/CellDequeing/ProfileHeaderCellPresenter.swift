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
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? ProfileHeaderCell {
            let ratio: CGFloat = 16.0/9.0
            let user = streamCellItem.jsonable as! User
            cell.user = user
            cell.currentUser = currentUser

            cell.onWebContentReady { webView in
                let webViewHeight = webView.windowContentSize()?.height ?? 0
                let actualHeight = ProfileHeaderCellSizeCalculator.calculateHeightBasedOn(
                    webViewHeight: webViewHeight,
                    nameSize: cell.nameLabel.frame.size,
                    width: cell.frame.size.width
                    )
                if actualHeight != streamCellItem.calculatedOneColumnCellHeight {
                    cell.webViewHeight.constant = webViewHeight

                    streamCellItem.calculatedWebHeight = webViewHeight
                    streamCellItem.calculatedOneColumnCellHeight = actualHeight
                    streamCellItem.calculatedMultiColumnCellHeight = actualHeight
                    postNotification(StreamNotification.UpdateCellHeightNotification, value: cell)
                }
            }

            let isCurrentUser = (user.id == currentUser?.id)

            if let cachedImage = TemporaryCache.load(.Avatar)
                where isCurrentUser
            {
                cell.setAvatar(cachedImage)
            }
            else if let url = user.avatar?.original?.url ?? user.avatar?.optimized?.url {
                cell.setAvatarURL(url)
            }

            cell.viewTopConstraint.constant = UIWindow.windowWidth() / ratio
            if let height = streamCellItem.calculatedWebHeight {
                cell.webViewHeight.constant = height
            }
            cell.usernameLabel.text = user.atName
            cell.nameLabel.setLabelText(user.name, color: cell.nameLabel.textColor)
            cell.bioWebView.loadHTMLString(StreamTextCellHTML.postHTML(user.headerHTMLContent), baseURL: NSURL(string: "/"))
            if let height = streamCellItem.calculatedWebHeight {
                cell.bioWebView.frame.size.height = height
            }

            let postCount = user.postsCount?.numberToHuman(showZero: true) ?? "0"
            cell.postsButton.title = InterfaceString.Profile.PostsCount
            cell.postsButton.count = postCount
            if let postCount = user.postsCount where postCount > 0 {
                cell.postsButton.enabled = true
            }
            else {
                cell.postsButton.enabled = false
            }

            let followingCount = user.followingCount?.numberToHuman(showZero: true) ?? "0"
            cell.followingButton.title = InterfaceString.Profile.FollowingCount
            cell.followingButton.count = followingCount


            let lovesCount = user.lovesCount?.numberToHuman(showZero: true) ?? "0"
            cell.lovesButton.title = InterfaceString.Profile.LovesCount
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
            cell.followersButton.title = InterfaceString.Profile.FollowersCount
            cell.followersButton.count = fCount
        }
    }
}
