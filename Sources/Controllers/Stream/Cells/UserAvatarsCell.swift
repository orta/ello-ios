//
//  UserAvatarsCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class UserAvatarsCell: UICollectionViewCell {
    static let reuseIdentifier = "UserAvatarsCell"

    @IBOutlet weak public var imageView: UIImageView!
    @IBOutlet weak public var loadingLabel: UILabel!
    @IBOutlet weak public var seeAllButton: UIButton!
    @IBOutlet weak public var avatarsView: UIView!
    var users = [User]()
    var avatarButtons = [AvatarButton]()
    var maxAvatars: Int {
        return Int(floor((UIWindow.windowWidth() - seeAllButton.frame.size.width - 65) / 40.0))
    }
    var userAvatarCellModel: UserAvatarCellModel? {
        didSet {
            if let model = userAvatarCellModel {
                users = model.users ?? [User]()
                updateAvatars()
            }
        }
    }
    weak var userDelegate: UserDelegate?
    weak var simpleStreamDelegate: SimpleStreamDelegate?

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    private func style() {
        loadingLabel.textColor = UIColor.greyA()
        loadingLabel.font = UIFont.typewriterFont(12)
        seeAllButton.titleLabel?.textColor = UIColor.greyA()
        seeAllButton.titleLabel?.font = UIFont.typewriterFont(12)
        avatarsView.clipsToBounds = true
    }

    private func updateAvatars() {
        clearButtons()
        let numToDisplay = min(users.count, maxAvatars)
        seeAllButton.hidden = users.count <= numToDisplay
        let usersToDisplay = users[0..<numToDisplay]
        var startX = 0.0
        for user in usersToDisplay {
            let ab = AvatarButton()
            ab.frame = CGRect(x: startX, y: 0.0, width: 30.0, height: 30.0)
            ab.setUser(user)
            ab.addTarget(self, action: Selector("avatarTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            avatarsView.addSubview(ab)
            avatarButtons.append(ab)
            startX += 40.0
        }
    }

    private func clearButtons() {
        for ab in avatarButtons {
            ab.removeFromSuperview()
        }
        avatarButtons = [AvatarButton]()
    }

    @IBAction func seeMoreTapped(sender: UIButton) {
        if let model = userAvatarCellModel, let endpoint = model.endpoint {
            simpleStreamDelegate?.showSimpleStream(endpoint, title: model.seeMoreTitle, noResultsMessages: nil)
        }
    }

    @IBAction func avatarTapped(sender: AvatarButton) {
        if let index = avatarButtons.indexOf(sender) {
            if users.count > index {
                let user = users[index]
                userDelegate?.userTappedParam(user.id)
            }
        }
    }
}
