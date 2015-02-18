//
//  ProfileHeaderCellConfig.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

extension ProfileHeaderCell: ConfigurableCell {

    func configure(streamCellItem:StreamCellItem, streamKind: StreamKind, indexPath: NSIndexPath) {
        let user = streamCellItem.jsonable as User

        if let avatarURL = user.avatarURL? {
            self.setAvatarURL(avatarURL)
        }

        self.usernameLabel.text = user.atName
        self.nameLabel.text = user.name
    }
    
}