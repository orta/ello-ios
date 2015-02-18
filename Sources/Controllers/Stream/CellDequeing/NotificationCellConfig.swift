//
//  NotificationCellConfig.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

extension NotificationCell: ConfigurableCell {

    func configure(streamCellItem:StreamCellItem, streamKind: StreamKind, indexPath: NSIndexPath) {
        var activity = streamCellItem.jsonable as Activity
        var post = activity.subject as Post

        self.title = NSAttributedString(string: "\(post.author!.atName) reposted your post.")
        self.messageHtml = "<b>HOPE</b> this <i>works</i>!"
        self.avatarURL = post.author?.avatarURL
    }
    
}