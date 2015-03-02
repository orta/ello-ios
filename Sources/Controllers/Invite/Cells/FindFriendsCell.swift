//
//  FindFriendsCell.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class FindFriendsCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var relationshipView: RelationshipView?

    override func layoutSubviews() {
        super.layoutSubviews()

        profileImageView?.layer.cornerRadius = 15.0

        nameLabel?.font = UIFont.typewriterFont(14)
        nameLabel?.textColor = UIColor.greyA()
    }
}
