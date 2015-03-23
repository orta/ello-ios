//
//  StreamCreateCommentCell.swift
//  Ello
//
//  Created by Colin Gray on 3/10/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import FLAnimatedImage

class StreamCreateCommentCell : UICollectionViewCell {
    struct Size {
        static let Height : CGFloat = 75
        static let Margins = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        static let AvatarButtonMargin : CGFloat = 12
        static let ButtonLabelMargin : CGFloat = 30
        static let ImageHeight : CGFloat = 30
    }

    let avatarView = FLAnimatedImageView()
    let createCommentBackground = CreateCommentBackgroundView()
    let createCommentLabel = UILabel()

    var avatarURL : NSURL? {
        willSet(value) {
            if let avatarURL = value {
                self.avatarView.sd_setImageWithURL(avatarURL)
            }
            else {
                self.avatarView.image = nil
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupViews() {
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(createCommentBackground)
        createCommentBackground.addSubview(createCommentLabel)

        avatarView.backgroundColor = UIColor.blackColor()
        avatarView.clipsToBounds = true

        // the size of this frame is not important, it's just used to "seed" the
        // autoresizingMask calculations
        createCommentBackground.frame = CGRect(x: 0, y: 0, width: 100, height: Size.Height)

        createCommentLabel.frame = createCommentBackground.bounds.inset(top: 0, left: Size.ButtonLabelMargin, bottom: 0, right: 0)
        createCommentLabel.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        createCommentLabel.text = "Comment..."
        createCommentLabel.font = UIFont.typewriterFont(12)
        createCommentLabel.textColor = UIColor.whiteColor()
        createCommentLabel.textAlignment = .Left
    }

    override func layoutSubviews() {
        let imageY = (self.frame.height - Size.ImageHeight) / CGFloat(2)
        avatarView.frame = CGRect(x: Size.Margins.left, y: imageY, width: Size.ImageHeight, height: Size.ImageHeight)
        avatarView.layer.cornerRadius = Size.ImageHeight / CGFloat(2)

        let createBackgroundLeft = avatarView.frame.maxX + Size.AvatarButtonMargin
        let createBackgroundWidth = self.frame.width - createBackgroundLeft - Size.Margins.right
        createCommentBackground.frame = CGRect(x: createBackgroundLeft, y: Size.Margins.top, width: createBackgroundWidth, height: self.frame.height - Size.Margins.top - Size.Margins.bottom)
    }

}
