//
//  StreamHeaderCellConfig.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

extension StreamHeaderCell: ConfigurableCell {

    func configure(streamCellItem:StreamCellItem, streamKind: StreamKind, indexPath: NSIndexPath) {
        if streamCellItem.type == .Header {
            self.streamKind = streamKind
        }

        if let avatarURL = (streamCellItem.jsonable as Authorable).author?.avatarURL? {
            self.setAvatarURL(avatarURL)
        }

        self.timestampLabel.text = NSDate().distanceOfTimeInWords((streamCellItem.jsonable as Authorable).createdAt)
        self.usernameLabel.text = ((streamCellItem.jsonable as Authorable).author?.atName ?? "@meow")
    }
}
