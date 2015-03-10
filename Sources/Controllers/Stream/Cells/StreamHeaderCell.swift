//
//  StreamHeaderCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation



class StreamHeaderCell: UICollectionViewCell {

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var userNameLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarBottomConstraint: NSLayoutConstraint!

    var calculatedHeight:CGFloat = 80.0
    var streamKind:StreamKind?
    weak var userDelegate: UserDelegate?

    func setAvatarURL(url:NSURL?) {
        avatarButton.setAvatarURL(url)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        styleUsernameLabel()
        styleTimestampLabel()
    }

    override func updateConstraints() {
        if let streamKind = streamKind {
            if streamKind.isGridLayout {
                self.userNameLeadingConstraint.constant = 14.0
            }
            else {
                self.userNameLeadingConstraint.constant = 20.0
            }
        }

        super.updateConstraints()
    }

    private func styleUsernameLabel() {
        usernameLabel.textColor = UIColor.greyA()
        usernameLabel.font = UIFont.typewriterFont(14.0)
    }

    private func styleTimestampLabel() {
        timestampLabel.textColor = UIColor.greyA()
        timestampLabel.font = UIFont.typewriterFont(14.0)
    }

    // MARK: - IBActions

    @IBAction func userTapped(sender: AvatarButton) {
        userDelegate?.userTappedCell(self)
    }

}
