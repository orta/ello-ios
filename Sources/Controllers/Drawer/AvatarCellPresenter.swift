//
//  AvatarCellPresenter.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

struct AvatarCellPresenter {
    static func configure(cell: AvatarCell, user: User) {
        cell.setAvatar(user.avatarURL)
    }
}

