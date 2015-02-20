//
//  NotificationCell.swift
//  Ello
//
//  Created by Colin Gray on 2/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


class NotificationCell : UICollectionViewCell {
    class func generateTextView(#frame: CGRect) -> UITextView {
        let textView = UITextView(frame: frame)
        textView.editable = false
        textView.allowsEditingTextAttributes = false
        textView.selectable = false
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textColor = UIColor.blackColor()
        textView.font = UIFont.typewriterFont(12)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    struct Size {
        static let sideMargins = CGFloat(15)
        static let avatarSide = CGFloat(30)
        static let leftTextMargin = CGFloat(10)
        static let imageWidth = CGFloat(87)
        static let topBottomMargins = CGFloat(30)
        static let innerTextMargin = CGFloat(10)
        static let createdAtHeight = CGFloat(12)

        // height of created at and title labels
        static func topBottomFixedHeight() -> CGFloat {
            let createdAtHeight = CGFloat(12)
            let innerMargin = self.innerTextMargin
            return createdAtHeight + innerMargin
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

    var avatarButton : AvatarButton!
    var titleTextView : UITextView!
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
            titleTextView.attributedText = newValue
        }
    }

    var createdAt: NSDate? {
        willSet(newValue) {
            if let date = newValue {
                createdAtLabel.text = NSDate().distanceOfTimeInWords(date)
            }
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

    override init(frame: CGRect) {
        super.init(frame: frame)

        avatarButton = AvatarButton()
        titleTextView = NotificationCell.generateTextView()
        notificationImageView = UIImageView()
        messageWebView = UIWebView()
        createdAtLabel = UILabel()

        titleTextView.editable = false
        titleTextView.allowsEditingTextAttributes = false
        titleTextView.selectable = false
        titleTextView.scrollEnabled = false
        titleTextView.textContainerInset = UIEdgeInsetsZero
        titleTextView.textColor = UIColor.blackColor()
        titleTextView.font = UIFont.typewriterFont(12)
        titleTextView.textContainer.lineFragmentPadding = 0

        let recognizer = UITapGestureRecognizer(target: self, action: "titleTapped:")
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        titleTextView.addGestureRecognizer(recognizer)

        createdAtLabel.textColor = UIColor.greyA()
        createdAtLabel.font = UIFont.typewriterFont(12)
        createdAtLabel.text = "10m"

        for view in [avatarButton, titleTextView, notificationImageView, messageWebView, createdAtLabel] {
            self.contentView.addSubview(view)
        }
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc
    func titleTapped(gesture : UITapGestureRecognizer) {
        let lbl = titleTextView
        let location = gesture.locationInView(lbl)
        let range = lbl.characterRangeAtPoint(location)
        let pos = lbl.closestPositionToPoint(location, withinRange: range)
        let style = lbl.textStylingAtPosition(pos, inDirection: .Forward) as [String : AnyObject]
        let linkType = style[Attributed.Link] as String?
        if let linkType = linkType {
            switch linkType {
                case "post":
                    let post = style[Attributed.Object] as Post
                    println("post: \(post)")
                case "comment":
                    let comment = style[Attributed.Object] as Comment
                    println("comment: \(comment)")
                case "user":
                    let user = style[Attributed.Object] as User
                    println("user: \(user)")
                default:
                    println("")
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let outerFrame = self.contentView.bounds.inset(all: Size.sideMargins)
        let titleWidth = Size.messageHtmlWidth(forCellWidth: self.frame.width, hasImage: imageURL != nil)

        avatarButton.frame = outerFrame.withSize(CGSize(width: Size.avatarSide, height: Size.avatarSide))

        if imageURL == nil {
            notificationImageView.frame = CGRectZero
        }
        else {
            notificationImageView.frame = outerFrame.fromRight()
                .growLeft(Size.imageWidth)
                .withHeight(Size.imageWidth / aspectRatio)
        }

        titleTextView.frame = avatarButton.frame.fromRight()
            .shiftRight(Size.innerTextMargin)
            .withWidth(titleWidth)
        titleTextView.sizeToFit()

        let createdAtHeight = Size.createdAtHeight
        createdAtLabel.frame = avatarButton.frame.fromRight()
            .shiftRight(Size.innerTextMargin)
            .atY(outerFrame.maxY - createdAtHeight)
            .withSize(CGSize(width: titleWidth, height: createdAtHeight))

        if messageHtml == nil {
            messageWebView.frame = CGRectZero
        }
        else {
            let remainingHeight = outerFrame.height - Size.innerTextMargin - titleTextView.frame.height
            messageWebView.frame = titleTextView.frame.fromBottom()
                .shiftDown(Size.innerTextMargin)
                .withHeight(remainingHeight)
        }
    }

}
