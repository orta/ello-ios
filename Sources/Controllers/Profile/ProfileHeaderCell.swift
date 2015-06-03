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

@objc
public protocol PostsTappedResponder {
    func onPostsTapped()
}

public class ProfileHeaderCell: UICollectionViewCell {

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var relationshipControl: RelationshipControl!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bioWebView: UIWebView!
    @IBOutlet weak var profileButtonsView: UIView!
    @IBOutlet weak var editProfileButton: OutlineElloButton!
    @IBOutlet weak public var postsButton: TwoLineButton!
    @IBOutlet weak var followersButton: TwoLineButton!
    @IBOutlet weak var followingButton: TwoLineButton!
    @IBOutlet weak var lovesButton: TwoLineButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var nsfwLabel: ElloLabel!
    @IBOutlet weak var usernameRightConstraint: NSLayoutConstraint!
    weak var webLinkDelegate: WebLinkDelegate?
    weak var userListDelegate: UserListDelegate?
    var user: User?

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
        bioWebView.delegate = self
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        bioWebView.scrollView.scrollEnabled = false
        bioWebView.scrollView.scrollsToTop = false
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        bioWebView.stopLoading()
    }

    func setAvatarURL(url: NSURL) {
        avatarButton.setAvatarURL(url)
    }

    func setAvatarImage(image: UIImage) {
        avatarButton.setImage(image, forState: .Normal)
    }

    private func style() {
        usernameLabel.font = UIFont.regularBoldFont(18.0)
        usernameLabel.textColor = UIColor.blackColor()

        nsfwLabel.font = UIFont.typewriterFont(10.0)
        nsfwLabel.textColor = UIColor.greyA()
        nsfwLabel.backgroundColor = UIColor.greyE5()
        nsfwLabel.text = NSLocalizedString("NSFW", comment: "Not Safe For Work")

        nameLabel.font = UIFont.typewriterFont(12.0)
        nameLabel.textColor = UIColor.greyA()

        profileButtonsView.backgroundColor = UIColor.whiteColor()

        inviteButton.setTitle("", forState: .Normal)
        inviteButton.setSVGImages("xpmcirc")
        inviteButton.addTarget(self, action: Selector("inviteTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
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

    @IBAction func followingTapped(sender: UIButton) {
        if let user = user {
            userListDelegate?.show(.UserStreamFollowing(userId: user.id), title: NSLocalizedString("Following", comment: "Following title"))
        }
    }

    @IBAction func followersTapped(sender: UIButton) {
        if let user = user {
            userListDelegate?.show(.UserStreamFollowers(userId: user.id), title: NSLocalizedString("Followers", comment: "Followers title"))
        }
    }

    @IBAction func postsTapped(sender: UIButton) {
        let responder = targetForAction("onPostsTapped", withSender: self) as? PostsTappedResponder
        responder?.onPostsTapped()
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
