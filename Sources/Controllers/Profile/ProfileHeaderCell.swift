//
//  ProfileHeaderCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Foundation

@objc protocol EditProfileResponder {
    func editProfile()
}

class ProfileHeaderCell: UICollectionViewCell {

    var coverWidthSet: Bool = false
    let ratio:CGFloat = 16.0/9.0

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countsTextView: ElloTextView!
    @IBOutlet weak var relationshipView: RelationshipView!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bioWebView: UIWebView!
    weak var webLinkDelegate: WebLinkDelegate?
    weak var userListDelegate: UserListDelegate?
    var currentUser: User?

    override func awakeFromNib() {
        super.awakeFromNib()
        styleLabels()
        countsTextView.textViewDelegate = self
        bioWebView.delegate = self
        if !coverWidthSet {
            coverWidthSet = true
            viewTopConstraint.constant = frame.width / ratio
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bioWebView.scrollView.scrollEnabled = false
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

    @IBAction func editProfile() {
        let responder = targetForAction("editProfile", withSender: self) as? EditProfileResponder
        responder?.editProfile()
    }
}

extension ProfileHeaderCell: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        if let jsResult = webView.stringByEvaluatingJavaScriptFromString("window.contentHeight()") {
            webView.frame = CGRect(x: webView.frame.x, y: webView.frame.y, width: webView.frame.width, height: CGFloat((jsResult as NSString).doubleValue))
        }
        bioWebView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitUserSelect='none';")
        bioWebView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitTouchCallout='none';")
        UIView.animateWithDuration(0.15, animations: {
            self.contentView.alpha = 1.0
        })
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