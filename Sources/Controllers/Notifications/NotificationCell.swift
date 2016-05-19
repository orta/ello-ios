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
    func commentTapped(comment: ElloComment)
    func postTapped(post: Post)
}

public class NotificationCell: UICollectionViewCell, UIWebViewDelegate {
    static let reuseIdentifier = "NotificationCell"

    struct Size {
        static let ButtonHeight = CGFloat(30)
        static let ButtonMargin = CGFloat(15)
        static let WebHeightCorrection = CGFloat(15)
        static let SideMargins = CGFloat(15)
        static let AvatarSize = CGFloat(30)
        static let ImageWidth = CGFloat(87)
        static let InnerMargin = CGFloat(10)
        static let CreatedAtHeight = CGFloat(10)

        // height of created at and margin from title / notification text
        static func createdAtFixedHeight() -> CGFloat {
            return CreatedAtHeight + InnerMargin
        }

        static func messageHtmlWidth(forCellWidth cellWidth: CGFloat, hasImage: Bool) -> CGFloat {
            let messageLeftMargin: CGFloat = SideMargins + AvatarSize + InnerMargin
            var messageRightMargin: CGFloat = InnerMargin
            if hasImage {
                messageRightMargin += InnerMargin + ImageWidth
            }
            return cellWidth - messageLeftMargin - messageRightMargin
        }

        static func imageHeight(imageRegion imageRegion: ImageRegion?) -> CGFloat {
            if let imageRegion = imageRegion {
                let aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
                return ImageWidth / aspectRatio
            }
            else {
                return 0
            }
        }
    }

    typealias OnHeightMismatch = (CGFloat) -> Void
    typealias WebContentReady = (webView: UIWebView) -> Void

    var webLinkDelegate: WebLinkDelegate?
    var userDelegate: UserDelegate?
    var delegate: NotificationDelegate?
    var webContentReady: WebContentReady?
    var onHeightMismatch: OnHeightMismatch?

    var avatarButton: AvatarButton!
    var replyButton: ReplyButton!
    var relationshipControl: RelationshipControl!
    var titleTextView: ElloTextView!
    var createdAtLabel: UILabel!
    var messageWebView: UIWebView!
    var notificationImageView: FLAnimatedImageView!
    var aspectRatio: CGFloat = 4/3
    var separator = UIView()

    var canReplyToComment: Bool {
        set {
            replyButton.hidden = !newValue
            setNeedsLayout()
        }
        get { return !replyButton.hidden }
    }
    var canBackFollow: Bool {
        set {
            relationshipControl.hidden = !newValue
            setNeedsLayout()
        }
        get { return !relationshipControl.hidden }
    }

    var messageHtml: String? {
        willSet {
            if newValue != messageHtml {
                if let value = newValue {
                    messageWebView.alpha = 0.0
                    messageWebView.loadHTMLString(StreamTextCellHTML.postHTML(value), baseURL: NSURL(string: "/"))
                }
                else {
                    messageWebView.loadHTMLString("", baseURL: NSURL(string: "/"))
                }
            }
        }
    }

    var imageURL: NSURL? {
        didSet {
            self.notificationImageView.pin_setImageFromURL(imageURL) { result in
                let success = result.image != nil || result.animatedImage != nil
                let isAnimated = result.animatedImage != nil
                if success {
                    let imageSize = isAnimated ? result.animatedImage.size : result.image.size
                    self.aspectRatio = imageSize.width / imageSize.height
                    let currentRatio = self.notificationImageView.frame.width / self.notificationImageView.frame.height
                    if currentRatio != self.aspectRatio {
                        let width = min(imageSize.width, self.frame.width)
                        let actualHeight = width / self.aspectRatio
                        self.onHeightMismatch?(actualHeight)
                    }
                }
            }
            self.setNeedsLayout()
        }
    }

    var title: NSAttributedString? {
        didSet {
            titleTextView.attributedText = title
        }
    }

    var createdAt: NSDate? {
        didSet {
            if let date = createdAt {
                createdAtLabel.text = date.timeAgoInWords()
            }
            else {
                createdAtLabel.text = ""
            }
        }
    }

    var user: User? {
        didSet {
            setUser(user)
        }
    }
    var post: Post?
    var comment: ElloComment?

    override init(frame: CGRect) {
        super.init(frame: frame)

        avatarButton = AvatarButton()
        avatarButton.addTarget(self, action: #selector(avatarTapped), forControlEvents: .TouchUpInside)
        titleTextView = ElloTextView(frame: CGRectZero, textContainer: nil)
        titleTextView.textViewDelegate = self

        replyButton = ReplyButton()
        replyButton.hidden = true
        replyButton.addTarget(self, action: #selector(replyTapped), forControlEvents: .TouchUpInside)

        relationshipControl = RelationshipControl()
        relationshipControl.hidden = true
        relationshipControl.showStarButton = false

        notificationImageView = FLAnimatedImageView()
        notificationImageView.contentMode = .ScaleAspectFit
        messageWebView = UIWebView()
        messageWebView.opaque = false
        messageWebView.backgroundColor = .clearColor()
        messageWebView.scrollView.scrollEnabled = false
        messageWebView.delegate = self

        createdAtLabel = UILabel()
        createdAtLabel.textColor = UIColor.greyA()
        createdAtLabel.font = UIFont.defaultFont(12)
        createdAtLabel.text = ""

        separator.backgroundColor = .greyE5()

        for view in [avatarButton, titleTextView, messageWebView,
                     notificationImageView, createdAtLabel,
                     replyButton, relationshipControl, separator] {
            self.contentView.addSubview(view)
        }
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func onWebContentReady(handler: WebContentReady?) {
        webContentReady = handler
    }

    private func setUser(user: User?) {
        avatarButton.setUser(user)

        relationshipControl.userId = user?.id ?? ""
        relationshipControl.userAtName = user?.atName ?? ""
        relationshipControl.relationshipPriority = user?.relationshipPriority ?? RelationshipPriority.None
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let outerFrame = contentView.bounds.inset(all: Size.SideMargins)
        let titleWidth = Size.messageHtmlWidth(forCellWidth: self.frame.width, hasImage: imageURL != nil)
        separator.frame = contentView.bounds.fromBottom().growUp(1)

        avatarButton.frame = outerFrame.withSize(CGSize(width: Size.AvatarSize, height: Size.AvatarSize))

        if imageURL == nil {
            notificationImageView.frame = CGRectZero
        }
        else {
            notificationImageView.frame = outerFrame.fromRight()
                .growLeft(Size.ImageWidth)
                .withHeight(Size.ImageWidth / aspectRatio)
        }

        titleTextView.frame = avatarButton.frame.fromRight()
            .shiftRight(Size.InnerMargin)
            .withWidth(titleWidth)

        let tvSize = titleTextView.sizeThatFits(CGSize(width: titleWidth, height: .max))
        titleTextView.frame.size.height = ceil(tvSize.height)

        var createdAtY = outerFrame.maxY - Size.CreatedAtHeight
        if !relationshipControl.hidden || !replyButton.hidden {
            createdAtY -= Size.ButtonMargin + Size.ButtonHeight
        }

        createdAtLabel.frame = CGRect(
            x: avatarButton.frame.maxX + Size.InnerMargin,
            y: createdAtY,
            width: titleWidth,
            height: 12
            )

        let replyButtonWidth = replyButton.intrinsicContentSize().width
        replyButton.frame = CGRect(
            x: createdAtLabel.frame.x,
            y: outerFrame.maxY - Size.ButtonHeight,
            width: replyButtonWidth,
            height: Size.ButtonHeight
            )
        let relationshipControlWidth = relationshipControl.intrinsicContentSize().width
        relationshipControl.frame = replyButton.frame.withWidth(relationshipControlWidth)

        if messageHtml == nil {
            messageWebView.frame = CGRectZero
        }
        else {
            let remainingHeight = outerFrame.height - Size.InnerMargin - titleTextView.frame.height
            messageWebView.frame = titleTextView.frame.fromBottom()
                .withWidth(titleWidth)
                .shiftDown(Size.InnerMargin)
                .withHeight(remainingHeight)
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        messageWebView.stopLoading()
        messageHtml = nil
        avatarButton.pin_cancelImageDownload()
        avatarButton.setImage(nil, forState: .Normal)
        notificationImageView.pin_cancelImageDownload()
        notificationImageView.image = nil
        aspectRatio = 4/3
        canReplyToComment = false
        canBackFollow = false
        imageURL = nil
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

    public func replyTapped() {
        if let post = post {
            delegate?.postTapped(post)
        }
        else if let comment = comment {
            delegate?.commentTapped(comment)
        }
    }

    public func avatarTapped() {
        userDelegate?.userTappedAuthor(self)
    }

}
