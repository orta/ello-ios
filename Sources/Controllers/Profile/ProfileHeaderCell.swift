//
//  ProfileHeaderCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Foundation

@objc
public protocol EditProfileResponder {
    func onEditProfile()
}

@objc
public protocol ViewUsersLovesResponder {
    func onViewUsersLoves()
}

public class ProfileHeaderCell: UICollectionViewCell {

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countsTextView: ElloTextView!
    @IBOutlet weak var relationshipControl: RelationshipControl!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bioWebView: UIWebView!
    @IBOutlet weak var profileButtonsView: UIView!
    @IBOutlet weak var editProfileButton: OutlineElloButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var lovesButton: UIButton!
    weak var webLinkDelegate: WebLinkDelegate?
    weak var userListDelegate: UserListDelegate?
    var currentUser: User?

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
        countsTextView.textViewDelegate = self
        bioWebView.delegate = self
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        bioWebView.scrollView.scrollEnabled = false
    }

    func setAvatarURL(url:NSURL) {
        avatarButton.setAvatarURL(url)
    }

    private func style() {
        usernameLabel.font = UIFont.regularBoldFont(24.0)
        usernameLabel.textColor = UIColor.blackColor()

        nameLabel.font = UIFont.typewriterFont(12.0)
        nameLabel.textColor = UIColor.greyA()

        countsTextView.font = UIFont.typewriterFont(12.0)
        countsTextView.textColor = UIColor.greyA()

        profileButtonsView.backgroundColor = UIColor.whiteColor()

        inviteButton.setTitle("", forState: .Normal)
        inviteButton.setSVGImages("xpmcirc")

        inviteButton.addTarget(self, action: Selector("inviteTapped:"), forControlEvents: UIControlEvents.TouchUpInside)

        lovesButton.setTitle("", forState: UIControlState.Normal)
        lovesButton.setSVGImages("heartslist")
        lovesButton.addTarget(self, action: Selector("lovesTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
    }

    @IBAction func editProfileTapped(sender: UIButton) {
        let responder = targetForAction("onEditProfile", withSender: self) as? EditProfileResponder
        responder?.onEditProfile()
    }

    @IBAction func inviteTapped(sender: UIButton) {
        let responder = targetForAction("onInviteFriends", withSender: self) as? InviteResponder
        responder?.onInviteFriends()
    }

    @IBAction func lovesTapped(sender: UIButton) {
        let responder = targetForAction("onViewUsersLoves", withSender: self) as? ViewUsersLovesResponder
        responder?.onViewUsersLoves()
    }
}

extension ProfileHeaderCell: UIWebViewDelegate {
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        UIView.animateWithDuration(0.15) {
            self.contentView.alpha = 1.0
        }
    }
}

extension ProfileHeaderCell: ElloTextViewDelegate {
    func textViewTapped(link: String, object: ElloAttributedObject) {
        switch object {
        case let .AttributedFollowers(user):
            userListDelegate?.show(.UserStreamFollowers(userId: user.id), title: NSLocalizedString("Followers", comment: "Followers title"))
        case let .AttributedFollowing(user):
            userListDelegate?.show(.UserStreamFollowing(userId: user.id), title: NSLocalizedString("Following", comment: "Following title"))
        default: break
        }
    }
}
