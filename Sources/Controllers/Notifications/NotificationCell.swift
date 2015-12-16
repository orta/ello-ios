//
//  NotificationCell.swift
//  Ello
//
//  Created by Colin Gray on 2/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import FLAnimatedImage
import TimeAgoInWords

@objc
public protocol NotificationDelegate {
    func userTapped(user: User)
    func commentTapped(comment: Comment)
    func postTapped(post: Post)
}

public class NotificationCell : UICollectionViewCell, UIWebViewDelegate {

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

        static func messageHtmlWidth(forCellWidth forCellWidth: CGFloat, hasImage: Bool) -> CGFloat {
            let messageLeftMargin : CGFloat = 55
            var messageRightMargin : CGFloat = 107
            if !hasImage {
                messageRightMargin = messageRightMargin - CGFloat(10) - self.imageWidth
            }
            return forCellWidth - messageLeftMargin - messageRightMargin
        }

        static func imageHeight(imageRegion imageRegion: ImageRegion?) -> CGFloat {
            if let imageRegion = imageRegion {
                let aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
                return self.imageWidth / aspectRatio
            }
            else {
                return 0
            }
        }
    }

    typealias WebContentReady = (webView : UIWebView) -> Void

    var webLinkDelegate: WebLinkDelegate?
    var userDelegate: UserDelegate?
    var delegate: NotificationDelegate?
    var webContentReady: WebContentReady?

    var avatarButton : AvatarButton!
    var titleTextView : ElloTextView!
    var createdAtLabel : UILabel!
    var messageWebView : UIWebView!
    var notificationImageView : FLAnimatedImageView!
    var aspectRatio:CGFloat = 4.0/3.0

    var messageHtml : String? {
        willSet(newValue) {
            messageWebView.alpha = 0.0
            if newValue != messageHtml {
                if let value = newValue {
                    messageWebView.loadHTMLString(StreamTextCellHTML.postHTML(value), baseURL: NSURL(string: "/"))
                }
                else {
                    messageWebView.loadHTMLString("", baseURL: NSURL(string: "/"))
                }
            }
        }
    }

    var imageURL : NSURL? {
        willSet(newValue) {
            self.notificationImageView.pin_setImageFromURL(newValue) { _ in
                self.setNeedsLayout()
            }
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
                createdAtLabel.text = date.timeAgoInWords()
            }
            else {
                createdAtLabel.text = ""
            }
        }
    }

    var user: User? {
        didSet {
            avatarButton.setUser(user)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        avatarButton = AvatarButton()
        avatarButton.addTarget(self, action: Selector("avatarTapped"), forControlEvents: .TouchUpInside)
        titleTextView = ElloTextView(frame: CGRectZero, textContainer: nil)
        titleTextView.textViewDelegate = self

        notificationImageView = FLAnimatedImageView()
        messageWebView = UIWebView()
        messageWebView.opaque = false
        messageWebView.backgroundColor = .clearColor()
        messageWebView.scrollView.scrollEnabled = false
        createdAtLabel = UILabel()

        messageWebView.delegate = self

        createdAtLabel.textColor = UIColor.greyA()
        createdAtLabel.font = UIFont.defaultFont()
        createdAtLabel.text = ""

        for view in [avatarButton, titleTextView, notificationImageView, messageWebView, createdAtLabel] {
            self.contentView.addSubview(view)
        }
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func onWebContentReady(handler: WebContentReady?) {
        webContentReady = handler
    }

    override public func layoutSubviews() {
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
                .withWidth(titleWidth)
                .shiftDown(Size.innerTextMargin)
                .withHeight(remainingHeight)
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        messageWebView.stopLoading()
        avatarButton.pin_cancelImageDownload()
        avatarButton.setImage(nil, forState: .Normal)
        notificationImageView.pin_cancelImageDownload()
        notificationImageView.image = nil
    }

    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.URL?.scheme
            where scheme == "default"
        {
            userDelegate?.userTappedText(self)
            return false
        }
        else {
            return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
        }
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        messageWebView.alpha = 1.0
        webContentReady?(webView: webView)
    }
}

extension NotificationCell: ElloTextViewDelegate {
    func textViewTapped(link: String, object: ElloAttributedObject) {
        switch object {
        case let .AttributedPost(post):
            delegate?.postTapped(post)
        case let .AttributedComment(comment):
            delegate?.commentTapped(comment)
        case let .AttributedUser(user):
            delegate?.userTapped(user)
        default: break
        }
    }

    func textViewTappedDefault() {
        userDelegate?.userTappedText(self)
    }
}

extension NotificationCell {

    @objc
    public func avatarTapped() {
        userDelegate?.userTappedAvatar(self)
    }

}
