//
//  InviteFriendsCell.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class InviteFriendsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var inviteButton: UIButton?

    var delegate: InviteDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()

        nameLabel?.font = UIFont.typewriterFont(14)
        nameLabel?.textColor = UIColor.greyA()

        inviteButton?.titleLabel?.font = UIFont.typewriterFont(14)
        inviteButton?.titleLabel?.textColor = UIColor.greyA()
        inviteButton?.layer.borderColor = UIColor.greyA().CGColor
        inviteButton?.layer.borderWidth = 1.0
    }

    @IBAction func invite() {
        delegate?.sendInvite()
    }
}
