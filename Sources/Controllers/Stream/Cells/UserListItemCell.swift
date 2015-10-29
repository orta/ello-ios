//
//  UserListItemCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class UserListItemCell: UICollectionViewCell {

    weak public var avatarButton: AvatarButton!
    @IBOutlet weak public var usernameLabel: UILabel!
    @IBOutlet weak public var nameLabel: UILabel!
    weak public var relationshipControl: RelationshipControl!
    weak var userDelegate: UserDelegate?
    var bottomBorder = CALayer()

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    func setUser(user: User?) {
        avatarButton.setUser(user)

        relationshipControl.userId = user?.id ?? ""
        relationshipControl.userAtName = user?.atName ?? ""
        relationshipControl.relationshipPriority = user?.relationshipPriority ?? RelationshipPriority.None

        usernameLabel.text = user?.atName ?? ""
        nameLabel.text = user?.name ?? ""
    }

    private func style() {
        usernameLabel.font = UIFont.regularBoldFont(18.0)
        usernameLabel.textColor = UIColor.blackColor()
        usernameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        nameLabel.font = UIFont.typewriterFont(12.0)
        nameLabel.textColor = UIColor.greyA()
        nameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail

        // bottom border
        bottomBorder.backgroundColor = UIColor.greyF1().CGColor
        self.layer.addSublayer(bottomBorder)
    }

    override public func layoutSubviews() {
        bottomBorder.frame = CGRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
        super.layoutSubviews()
    }

    @IBAction func userTapped(sender: AvatarButton) {
        userDelegate?.userTappedAvatar(self)
    }
}
