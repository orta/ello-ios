//
//  AvatarCellPresenter.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct AvatarCellPresenter: CellPresenter {
    public let reuseIdentifier = "AvatarCell"
    let user: User

    public func configureCell(cell: UICollectionViewCell) {
        let cell = cell as? AvatarCell
        cell?.setAvatar(user.avatarURL)
    }
}
