//
//  NotificationCell.swift
//  Ello
//
//  Created by Colin Gray on 2/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


class NotificationCell : UICollectionViewCell {
    struct Size {
        static let sideMargins = CGFloat(15)
        static let avatarSide = CGFloat(30)
        static let leftTextMargin = CGFloat(10)
        static let imageWidth = CGFloat(87)
        static let topBottomMargins = CGFloat(30)
        static let innerTextMargin = CGFloat(10)
        static let createdAtHeight = CGFloat(12)

        static func titleHeight(#attributedTitle: NSAttributedString?, forCellWidth cellWidth: CGFloat, hasImage: Bool) -> CGFloat {
            if let attributedTitle = attributedTitle {
                let textWidth = messageHtmlWidth(forCellWidth: cellWidth, hasImage: hasImage)
                let size = attributedTitle.boundingRectWithSize(CGSize(width: textWidth, height: 1_000), options: .UsesLineFragmentOrigin, context: nil).size
                return ceil(size.height)
            }
            else {
                return CGFloat(0)
            }
        }

        // height of created at and title labels
        static func topBottomFixedHeight(#attributedTitle: NSAttributedString?, forCellWidth cellWidth: CGFloat, hasImage: Bool) -> CGFloat {
            let titleHeight = Size.titleHeight(attributedTitle: attributedTitle, forCellWidth: cellWidth, hasImage: hasImage)
            let createdAtHeight = CGFloat(12)
            let innerMargin = self.innerTextMargin
            return createdAtHeight + titleHeight + innerMargin
        }

        static func messageHtmlWidth(#forCellWidth: CGFloat, hasImage: Bool) -> CGFloat {
            let messageLeftMargin : CGFloat = 55
            var messageRightMargin : CGFloat = 107
            if !hasImage {
                messageRightMargin = messageRightMargin - CGFloat(10) - self.imageWidth
            }
            return forCellWidth - messageLeftMargin - messageRightMargin
        }

        static func imageHeight(#imageRegion: ImageRegion?) -> CGFloat {
            if let imageRegion = imageRegion {
                var aspectRatio = StreamCellItemParser.aspectRatioForImageBlock(imageRegion)
                return self.imageWidth * aspectRatio
            }
            else {
                return 0
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        avatarButton = AvatarButton()
        notificationTitleLabel = UILabel()
        notificationImageView = UIImageView()
        messageWebView = UIWebView()
        createdAtLabel = UILabel()

        for label in [notificationTitleLabel, createdAtLabel] {
            label.textColor = UIColor.blackColor()
            label.font = UIFont.typewriterFont(12)
        }
        createdAtLabel.text = "10m"

        for view in [avatarButton, notificationTitleLabel, notificationImageView, messageWebView, createdAtLabel] {
            self.contentView.addSubview(view)
        }
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    var avatarButton : AvatarButton!
    var notificationTitleLabel : UILabel!
    var createdAtLabel : UILabel!
    var messageWebView : UIWebView!
    var notificationImageView : UIImageView!

    var aspectRatio:CGFloat = 4.0/3.0

    var messageHtml : String? {
        willSet(newValue) {
            if let value = newValue {
                messageWebView.loadHTMLString(StreamTextCellHTML.postHTML(newValue!), baseURL: NSURL(string: "/"))
            }
            else {
                messageWebView.loadHTMLString("", baseURL: NSURL(string: "/"))
            }
        }
    }

    var imageURL : NSURL? {
        willSet(newValue) {
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

    override func layoutSubviews() {
        super.layoutSubviews()

        let outerFrame = self.contentView.bounds.inset(all: Size.sideMargins)
        let titleWidth = Size.messageHtmlWidth(forCellWidth: self.frame.width, hasImage: imageURL != nil)
        let titleHeight = Size.titleHeight(attributedTitle: title, forCellWidth: self.frame.width, hasImage: imageURL != nil)

        avatarButton.frame = outerFrame.withSize(CGSize(width: Size.avatarSide, height: Size.avatarSide))

        if imageURL == nil {
            notificationImageView.frame = CGRectZero
        }
        else {
            notificationImageView.frame = outerFrame.fromRight()
                .growLeft(Size.imageWidth)
                .withHeight(Size.imageWidth / aspectRatio)
        }

        notificationTitleLabel.frame = avatarButton.frame.fromRight()
            .shiftRight(Size.innerTextMargin)
            .withSize(CGSize(width: titleWidth, height: titleHeight))

        let createdAtHeight = Size.createdAtHeight
        createdAtLabel.frame = avatarButton.frame.fromRight()
            .shiftRight(Size.innerTextMargin)
            .atY(outerFrame.maxY - createdAtHeight)
            .withSize(CGSize(width: titleWidth, height: createdAtHeight))

        if messageHtml == nil {
            messageWebView.frame = CGRectZero
        }
        else {
            let remainingHeight = outerFrame.height - Size.innerTextMargin - notificationTitleLabel.frame.height
            messageWebView.frame = notificationTitleLabel.frame.fromBottom()
                .shiftDown(Size.innerTextMargin)
                .withHeight(remainingHeight)
        }
    }

}
