//
//  InviteFriendsCell.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class InviteFriendsCell: UITableViewCell {
    @IBOutlet weak public var nameLabel: UILabel?
    @IBOutlet weak public var inviteButton: UIButton?

    var delegate: InviteDelegate?

    override public func awakeFromNib() {
        super.awakeFromNib()

        nameLabel?.font = UIFont.typewriterFont(14)
        nameLabel?.textColor = UIColor.greyA()
        inviteButton?.titleLabel?.font = UIFont.typewriterFont(12)
    }

    @IBAction func invite() {
        delegate?.sendInvite()
    }
}
