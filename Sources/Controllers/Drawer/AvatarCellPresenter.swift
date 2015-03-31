//
//  AvatarCellPresenter.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

struct AvatarCellPresenter: CellPresenter {
    let reuseIdentifier = "AvatarCell"
    let user: User

    func configureCell(cell: UICollectionViewCell) {
        let cell = cell as? AvatarCell
        cell?.setAvatar(user.avatarURL)
    }
}
