//
//  InviteFriendsCell.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class InviteFriendsCell: UITableViewCell {
    @IBOutlet weak var selectedImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?

    override func layoutSubviews() {
        super.layoutSubviews()

        selectedImageView?.layer.cornerRadius = 10.0
        selectedImageView?.backgroundColor = UIColor.greyE5()

        nameLabel?.font = UIFont.typewriterFont(14)
        nameLabel?.textColor = UIColor.greyA()
    }

    func didSelect() {
        selectedImageView?.image = UIImage(named: "friends-icon-selected")
        nameLabel?.textColor = UIColor.blackColor()
    }

    func didDeselect() {
        selectedImageView?.image = .None
        nameLabel?.textColor = UIColor.greyA()
    }
}
