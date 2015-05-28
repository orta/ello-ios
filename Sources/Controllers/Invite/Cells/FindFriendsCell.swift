//
//  FindFriendsCell.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import FLAnimatedImage

public class FindFriendsCell: UITableViewCell {
    @IBOutlet weak public var profileImageView: FLAnimatedImageView?
    @IBOutlet weak public var nameLabel: UILabel?
    @IBOutlet weak public var relationshipControl: RelationshipControl?

    override public func layoutSubviews() {
        super.layoutSubviews()
        selectionStyle = .None

        profileImageView?.layer.cornerRadius = 15.0

        nameLabel?.font = UIFont.typewriterFont(14)
        nameLabel?.textColor = UIColor.greyA()
    }
}
