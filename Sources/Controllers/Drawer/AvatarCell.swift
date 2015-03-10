//
//  AvatarCell.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/9/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class AvatarCell: UICollectionViewCell {
    @IBOutlet weak var avatarButton: AvatarButton!

    func setAvatar(url: NSURL?) {
        avatarButton.setAvatarURL(url)
    }
}

extension AvatarCell {
    class func nib() -> UINib {
        return UINib(nibName: "AvatarCell", bundle: .None)
    }

    class func reuseIdentifier() -> String {
        return "AvatarCell"
    }
}
