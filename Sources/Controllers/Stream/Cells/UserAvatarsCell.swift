//
//  UserAvatarsCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class UserAvatarsCell: UICollectionViewCell {

    @IBOutlet weak public var imageView: UIImageView!
    @IBOutlet weak public var seeAllButton: UIButton!
    weak var userDelegate: UserDelegate?

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    private func style() {

    }

    @IBAction func userTapped(sender: AvatarButton) {
        userDelegate?.userTappedCell(self)
    }
}
