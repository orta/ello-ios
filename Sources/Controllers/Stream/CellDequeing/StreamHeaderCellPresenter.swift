//
//  StreamHeaderCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import TimeAgoInWords

public struct StreamHeaderCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamHeaderCell {
            let authorable = streamCellItem.jsonable as! Authorable

            cell.ownPost = false

            if let currentUser = currentUser, let comment = authorable as? Comment {
                if comment.author?.id == currentUser.id ||
                    comment.parentPost?.author?.id == currentUser.id
                {
                    cell.ownPost = true
                }
            }

            if streamCellItem.type == .Header {
                cell.streamKind = streamKind
                cell.avatarHeight = streamKind.isGridLayout ? 30.0 : 60.0
                cell.scrollView.scrollEnabled = false
                cell.chevronHidden = true
                cell.goToPostView.hidden = false
            }

            cell.setAvatarURL(authorable.author?.avatarURL)
            cell.timeStamp = authorable.createdAt.timeAgoInWords()

            if streamCellItem.type == .CommentHeader {
                cell.avatarHeight = 30.0
                cell.scrollView.scrollEnabled = true
                cell.chevronHidden = false
                cell.goToPostView.hidden = true
            }
            let usernameText = authorable.author?.atName ?? ""
            cell.usernameTextView.text = ""
            cell.usernameTextView.appendTextWithAction(usernameText, link: "author", object: authorable.author)
            cell.resetUsernameTextView()
            cell.usernameTextView.sizeToFit()
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
    }
}
