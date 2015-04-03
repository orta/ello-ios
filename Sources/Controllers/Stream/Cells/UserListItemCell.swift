//
//  UserListItemCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class UserListItemCell: UICollectionViewCell {

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var relationshipView: RelationshipView!
    weak var userDelegate: UserDelegate?
    var currentUser: User?
    var bottomBorder = CALayer()

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    func setAvatarURL(url:NSURL) {
        avatarButton.setAvatarURL(url)
    }

    private func style() {
        usernameLabel.font = UIFont.typewriterFont(12.0)
        usernameLabel.textColor = UIColor.greyA()
        // bottom border
        bottomBorder.backgroundColor = UIColor.greyF1().CGColor
        self.layer.addSublayer(bottomBorder)
    }

    override public func layoutSubviews() {
        bottomBorder.frame = CGRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
        super.layoutSubviews()
    }


    @IBAction func userTapped(sender: AvatarButton) {
        userDelegate?.userTappedCell(self)
    }
}
