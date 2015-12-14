//
//  StreamCreateCommentCell.swift
//  Ello
//
//  Created by Colin Gray on 3/10/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import FLAnimatedImage

public class StreamCreateCommentCell: UICollectionViewCell {
    public struct Size {
        public static let Margins = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
        public static let AvatarButtonMargin: CGFloat = 6
        public static let ButtonLabelMargin: CGFloat = 30
        public static let ImageHeight: CGFloat = 30
    }

    public var indexPath = NSIndexPath(forItem: 0, inSection: 0)
    weak var delegate: PostbarDelegate?
    let avatarView = FLAnimatedImageView()
    let createCommentBackground = CreateCommentBackgroundView()
    let createCommentLabel = UILabel()
    let replyAllButton = UIButton()

    var avatarURL: NSURL? {
        willSet(value) {
            if let avatarURL = value {
                avatarView.pin_setImageFromURL(avatarURL)
            }
            else {
                avatarView.pin_cancelImageDownload()
                avatarView.image = nil
            }
        }
    }

    var replyAllVisibility: InteractionVisibility = .Disabled {
        didSet {
            replyAllButton.hidden = (replyAllVisibility != .Enabled)
            setNeedsLayout()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    private func setupViews() {
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(replyAllButton)
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(createCommentBackground)
        createCommentBackground.addSubview(createCommentLabel)

        replyAllButton.setImage(.ReplyAll, imageStyle: .Normal, forState: .Normal)
        replyAllButton.setImage(.ReplyAll, imageStyle: .Selected, forState: .Highlighted)
        replyAllButton.addTarget(self, action: Selector("replyAllTapped"), forControlEvents: .TouchUpInside)

        avatarView.backgroundColor = UIColor.blackColor()
        avatarView.clipsToBounds = true

        // the size of this frame is not important, it's just used to "seed" the
        // autoresizingMask calculations
        createCommentBackground.frame = CGRect(x: 0, y: 0, width: 100, height: StreamCellType.CreateComment.oneColumnHeight)

        createCommentLabel.frame = createCommentBackground.bounds.inset(top: 0, left: Size.ButtonLabelMargin, bottom: 0, right: 0)
        createCommentLabel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        createCommentLabel.text = "Comment..."
        createCommentLabel.font = UIFont.defaultFont()
        createCommentLabel.textColor = UIColor.whiteColor()
        createCommentLabel.textAlignment = .Left
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        avatarView.pin_cancelImageDownload()
    }

    override public func layoutSubviews() {
        let imageY = (self.frame.height - Size.ImageHeight) / CGFloat(2)
        avatarView.frame = CGRect(x: Size.Margins.left, y: imageY, width: Size.ImageHeight, height: Size.ImageHeight)
        avatarView.layer.cornerRadius = Size.ImageHeight / CGFloat(2)

        let createBackgroundLeft = avatarView.frame.maxX + Size.AvatarButtonMargin
        let createBackgroundWidth = self.frame.width - createBackgroundLeft - Size.Margins.right
        createCommentBackground.frame = CGRect(x: createBackgroundLeft, y: Size.Margins.top, width: createBackgroundWidth, height: self.frame.height - Size.Margins.top - Size.Margins.bottom)

        if replyAllVisibility == .Enabled {
            let btnSize = createCommentBackground.frame.height
            createCommentBackground.frame = createCommentBackground.frame.shrinkLeft(btnSize - Size.Margins.right)
            replyAllButton.frame = createCommentBackground.frame.fromRight().growRight(btnSize)
        }
    }

    func replyAllTapped() {
        delegate?.replyToAllButtonTapped(indexPath)
    }

}
