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

public class ProfileHeaderCell: UICollectionViewCell {

    var coverWidthSet: Bool = false
    let ratio:CGFloat = 16.0/9.0

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countsTextView: ElloTextView!
    @IBOutlet weak var relationshipView: RelationshipView!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bioWebView: UIWebView!
    @IBOutlet weak var profileButtonsView: UIView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    weak var webLinkDelegate: WebLinkDelegate?
    weak var userListDelegate: UserListDelegate?
    var currentUser: User?

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
        countsTextView.textViewDelegate = self
        bioWebView.delegate = self
        if !coverWidthSet {
            coverWidthSet = true
            viewTopConstraint.constant = frame.width / ratio
        }
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

        settingsButton.setTitle("", forState: UIControlState.Normal)
        settingsButton.setSVGImages("gear")
        settingsButton.addTarget(self, action: Selector("settingsTapped:"), forControlEvents: UIControlEvents.TouchUpInside)

        inviteButton.setTitle("", forState: UIControlState.Normal)
        inviteButton.setSVGImages("xpmcirc", rotation: 90)
        inviteButton.addTarget(self, action: Selector("inviteTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
    }

    @IBAction func settingsTapped(sender: UIButton) {
        let responder = targetForAction("onEditProfile", withSender: self) as? EditProfileResponder
        responder?.onEditProfile()
    }

    @IBAction func inviteTapped(sender: UIButton) {
        let responder = targetForAction("onInviteFriends", withSender: self) as? InviteResponder
        responder?.onInviteFriends()
    }
}

extension ProfileHeaderCell: UIWebViewDelegate {
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        let jsResult = webView.stringByEvaluatingJavaScriptFromString("window.contentHeight()") ?? "0.0"
        webView.frame.size.height = CGFloat((jsResult as NSString).doubleValue)
        UIView.animateWithDuration(0.15, animations: {
            self.contentView.alpha = 1.0
        })
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
