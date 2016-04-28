//
//  StreamInviteFriendsCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class StreamInviteFriendsCell: UICollectionViewCell {
    static let reuseIdentifier = "StreamInviteFriendsCell"

    @IBOutlet weak public var nameLabel: UILabel!
    @IBOutlet weak public var inviteButton: UIButton!

    public var inviteDelegate: InviteDelegate?
    public var inviteCache: InviteCache?
    var bottomBorder = CALayer()

    public var person: LocalPerson? {
        didSet {
            nameLabel.text = person!.name
            styleInviteButton(inviteCache?.has(person!.identifier))
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = UIFont.defaultFont()
        nameLabel.textColor = UIColor.greyA()
        nameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        inviteButton.titleLabel?.font = UIFont.defaultFont()
        // bottom border
        bottomBorder.backgroundColor = UIColor.greyF1().CGColor
        self.layer.addSublayer(bottomBorder)
    }

    override public func layoutSubviews() {
        bottomBorder.frame = CGRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
        super.layoutSubviews()
    }

    @IBAction func invite() {
        if let person = person {
            inviteDelegate?.sendInvite(person) {
                self.inviteCache?.saveInvite(person.identifier)
                self.styleInviteButton(self.inviteCache?.has(person.identifier))
            }
        }
    }

    public func styleInviteButton(invited: Bool? = false) {
        if invited == true {
            inviteButton.backgroundColor = UIColor.greyE5()
            inviteButton.setTitleColor(UIColor.grey6(), forState: UIControlState.Normal)
            inviteButton.setTitle(InterfaceString.Friends.Resend, forState: UIControlState.Normal)
        }
        else {
            inviteButton.backgroundColor = UIColor.greyA()
            inviteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            inviteButton.setTitle(InterfaceString.Friends.Invite, forState: UIControlState.Normal)
        }
    }
}
