//
//  NotificationCell.swift
//  Ello
//
//  Created by Colin Gray on 2/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


class NotificationCell : UICollectionViewCell {
    class func imageWidth() -> CGFloat {
        return CGFloat(87)
    }
    // total height of top/bottom margins
    class func topBottomMargins() -> CGFloat {
        return CGFloat(30)
    }
    // height of created at and title labels
    class func topBottomFixedHeight(#attributedTitle: NSAttributedString, forCellWidth cellWidth: CGFloat, hasImage: Bool) -> CGFloat {
        let textWidth = messageHtmlWidth(forCellWidth: cellWidth, hasImage: hasImage)
        let size = attributedTitle.boundingRectWithSize(CGSize(width: textWidth, height: 1_000), options: .UsesLineFragmentOrigin, context: nil).size
        let createdAtHeight = CGFloat(12)
        let titleHeight = ceil(size.height)
        let innerMargin = self.innerTextMargin()
        return createdAtHeight + titleHeight + innerMargin
    }
    class func innerTextMargin() -> CGFloat {
        return CGFloat(10)
    }

    @IBOutlet var avatarButton : AvatarButton!
    @IBOutlet var notificationTitleLabel : UILabel!
    @IBOutlet var messageWebView : UIWebView!
    @IBOutlet var notificationImageView : UIImageView!

    @IBOutlet var collapsableImageWidth : NSLayoutConstraint!
    @IBOutlet var collapsableImageHeight : NSLayoutConstraint!
    @IBOutlet var collapsableImageMargin : NSLayoutConstraint!
    @IBOutlet var collapsableMessageMargin : NSLayoutConstraint!

    var aspectRatio:CGFloat = 4.0/3.0

    var messageHtml : String? {
        willSet(newValue) {
            if let value = newValue {
                collapsableMessageMargin.constant = 10
                messageWebView.loadHTMLString(StreamTextCellHTML.postHTML(newValue!), baseURL: NSURL(string: "/"))
            }
            else {
                collapsableMessageMargin.constant = 0
                messageWebView.loadHTMLString("", baseURL: NSURL(string: "/"))
            }
        }
    }

    var imageURL : NSURL? {
        willSet(newValue) {
            if let image = newValue {
                collapsableImageWidth.constant = NotificationCell.imageWidth()
                collapsableImageHeight.constant = CGFloat(NotificationCell.imageWidth()) / aspectRatio
                collapsableImageMargin.constant = 10
            }
            else {
                collapsableImageWidth.constant = 0
                collapsableImageHeight.constant = 0
                collapsableImageMargin.constant = 0
            }
            self.notificationImageView.sd_setImageWithURL(newValue, completed: { (image, error, type, url) in
                self.setNeedsLayout()
            })
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

    class func messageHtmlWidth(#forCellWidth: CGFloat, hasImage: Bool) -> CGFloat {
        let messageLeftMargin : CGFloat = 55
        var messageRightMargin : CGFloat = 107
        if !hasImage {
            messageRightMargin = messageRightMargin - CGFloat(10) - self.imageWidth()
        }
        return forCellWidth - messageLeftMargin - messageRightMargin
    }

    class func imageHeight(#imageRegion: ImageRegion?) -> CGFloat {
        if let imageRegion = imageRegion {
            var aspectRatio = StreamCellItemParser.aspectRatioForImageBlock(imageRegion)
            return self.imageWidth() * aspectRatio
        }
        else {
            return 0
        }
    }

}
