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
    @IBOutlet weak var countsTextView: ElloTextView!
    @IBOutlet weak var relationshipView: RelationshipView!
    weak var userListDelegate: UserListDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        styleLabels()
        countsTextView.textViewDelegate = self
    }

    func setAvatarURL(url:NSURL) {
        avatarButton.setAvatarURL(url)
    }

    private func styleLabels() {
        usernameLabel.font = UIFont.regularBoldFont(18.0)
        usernameLabel.textColor = UIColor.blackColor()

        nameLabel.font = UIFont.typewriterFont(12.0)
        nameLabel.textColor = UIColor.greyA()

        countsTextView.font = UIFont.typewriterFont(12.0)
        countsTextView.textColor = UIColor.greyA()
    }
}

extension ProfileHeaderCell: ElloTextViewDelegate {
    func textViewTapped(link: String, object: AnyObject?) {
        switch link {
        case "followers":
            if let user = object as? User {
                userListDelegate?.show(.UserStreamFollowers(userId: user.userId), title: "Followers")
            }
        case "following":
            if let user = object as? User {
                userListDelegate?.show(.UserStreamFollowing(userId: user.userId), title: "Following")
            }
        default: break
        }
    }
}