//
//  NotificationCell.swift
//  Ello
//
//  Created by Colin Gray on 2/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


class NotificationCell : UICollectionViewCell {

    @IBOutlet var avatarButton : AvatarButton!
    @IBOutlet var notificationTitleLabel : UILabel!
    @IBOutlet var messageWebView : UIWebView!
    @IBOutlet var notificationImageView : UIImageView!

    @IBOutlet var collapsableImageMargin : NSLayoutConstraint!
    @IBOutlet var collapsableMessageMargin : NSLayoutConstraint!

    var messageHtml : String? {
        willSet(newValue) {
            if let value = newValue {
                collapsableMessageMargin.constant = 10
            }
            else {
                collapsableMessageMargin.constant = 0
            }
            messageWebView.loadHTMLString(StreamTextCellHTML.postHTML(newValue!), baseURL: NSURL(string: "/"))
        }
    }
    var image : UIImage? {
        willSet(newValue) {
            if let image = newValue {
                collapsableImageMargin.constant = 10
            }
            else {
                collapsableImageMargin.constant = 0
            }
            notificationImageView.image = newValue
        }
    }
    var title: NSAttributedString? {
        willSet(newValue) {
            notificationTitleLabel.attributedText = newValue
        }
    }
    var avatarURL: NSURL? {
        willSet(newValue) {
            if let url = newValue {
                avatarButton.setAvatarURL(url)
            }
            else {
                avatarButton.setImage(nil, forState: .Normal)
            }
        }
    }

}
