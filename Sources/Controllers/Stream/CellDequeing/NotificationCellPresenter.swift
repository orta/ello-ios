//
//  NotificationCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct NotificationCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? NotificationCell {
            var activity = streamCellItem.jsonable as Activity
            var post = activity.subject as Post

            cell.title = NSAttributedString(string: "\(post.author!.atName) reposted your post.")
            cell.messageHtml = "<b>HOPE</b> this <i>works</i>!"
            cell.avatarURL = post.author?.avatarURL
        }
    }
    
}