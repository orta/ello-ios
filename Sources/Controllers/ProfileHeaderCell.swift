//
//  ProfileHeaderCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Foundation

class ProfileHeaderCell: UICollectionViewCell {

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    func setAvatarURL(url:NSURL) {
        avatarButton.setAvatarURL(url)
    }
}

