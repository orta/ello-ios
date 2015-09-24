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
public protocol PostsTappedResponder {
    func onPostsTapped()
}

public class ProfileHeaderCell: UICollectionViewCell {

    weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    weak var relationshipControl: RelationshipControl!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bioWebView: UIWebView!
    @IBOutlet weak var profileButtonsView: UIView!
    @IBOutlet weak var editProfileButton: OutlineElloButton!
    weak public var postsButton: TwoLineButton!
    weak var followersButton: TwoLineButton!
    weak var followingButton: TwoLineButton!
    weak var lovesButton: TwoLineButton!
    @IBOutlet weak var inviteButton: UIButton!
    weak var nsfwLabel: ElloLabel!
    @IBOutlet weak var usernameRightConstraint: NSLayoutConstraint!
    weak var webLinkDelegate: WebLinkDelegate?
    weak var simpleStreamDelegate: SimpleStreamDelegate?
    var user: User?
    var currentUser: User?

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
        bioWebView.delegate = self
        editProfileButton.titleLabel?.font = UIFont.typewriterFont(12.0)
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

    @IBAction func followingTapped(sender: UIButton) {
        if let user = user {
            let noResultsTitle: String
            let noResultsBody: String
            if user.id == currentUser?.id {
                noResultsTitle = NSLocalizedString("You aren't following anyone yet!", comment: "No following results title")
                noResultsBody = NSLocalizedString("Ello is way more rad when you're following lots of people.\n\nUse Discover to find people you're interested in, and to find or invite your friends.\nYou can also use Search (upper right) to look for new and excellent people!", comment: "No following results body.")
            }
            else {
                noResultsTitle = "This person isn't following anyone yet!"
                noResultsBody = "Follow, mention them, comment, repost or love one of their posts and maybe they'll follow you back ;)"
            }
            simpleStreamDelegate?.showSimpleStream(.UserStreamFollowing(userId: user.id), title: NSLocalizedString("Following", comment: "Following title"), noResultsMessages: (title: noResultsTitle, body: noResultsBody))
        }
    }

    @IBAction func followersTapped(sender: UIButton) {
        if let user = user {
            let noResultsTitle: String
            let noResultsBody: String
            if user.id == currentUser?.id {
                noResultsTitle = NSLocalizedString("You don't have any followers yet!", comment: "No followers results title")
                noResultsBody = NSLocalizedString("Here's some tips on how to get new followers: use Discover to find people you're interested in, and to find or invite your friends. When you see things you like you can comment, repost, mention people and love the posts that you most enjoy. ", comment: "No followers results body.")
            }
            else {
                noResultsTitle = "This person doesn't have any followers yet! "
                noResultsBody = "Be the first to follow them and give them some love! Following interesting people makes Ello way more fun."
            }
            simpleStreamDelegate?.showSimpleStream(.UserStreamFollowers(userId: user.id), title: NSLocalizedString("Followers", comment: "Followers title"), noResultsMessages: (title: noResultsTitle, body: noResultsBody))
        }
    }

    @IBAction func lovesTapped(sender: UIButton) {
        if let user = user {
            let noResultsTitle: String
            let noResultsBody: String
            if user.id == currentUser?.id {
                noResultsTitle = NSLocalizedString("You haven't Loved any posts yet!", comment: "No loves results title")
                noResultsBody = NSLocalizedString("You can use Ello Loves as a way to bookmark the things you care about most. Go Love someone's post, and it will be added to this stream.", comment: "No loves results body.")
            }
            else {
                noResultsTitle = NSLocalizedString("This person hasn’t Loved any posts yet!", comment: "No loves results title")
                noResultsBody = NSLocalizedString("Ello Loves are a way to bookmark the things you care about most. When they love something the posts will appear here.", comment: "No loves results body.")
            }
            simpleStreamDelegate?.showSimpleStream(.Loves(userId: user.id), title: NSLocalizedString("Loves", comment: "love stream"), noResultsMessages: (title: noResultsTitle, body: noResultsBody))
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
