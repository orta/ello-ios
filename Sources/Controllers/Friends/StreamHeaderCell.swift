//
//  StreamHeaderCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

class StreamHeaderCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    var calculatedHeight:CGFloat = 80.0

    func setAvatarURL(url:NSURL) {

        avatarImageView.sd_setImageWithURL(url, completed: {
            (image, error, type, url) -> Void in

            if error == nil && image != nil {
                let size = self.avatarImageView.bounds.size
                self.avatarImageView.image = image.squareImageToSize(size)?.roundCorners()

                UIView.animateWithDuration(0.15, animations: {
                    self.contentView.alpha = 1.0
                })
            }
            else {
                self.avatarImageView.image = nil
            }
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        styleUsernameLabel()
        styleTimestampLabel()
    }

    private func styleUsernameLabel() {
        usernameLabel.textColor = UIColor.elloLightGray()
        usernameLabel.font = UIFont.typewriterFont(14.0)
    }

    private func styleTimestampLabel() {
        timestampLabel.textColor = UIColor.elloLightGray()
        timestampLabel.font = UIFont.typewriterFont(14.0)
    }

//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
//        let attributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
//        let newSize = CGSize(width: UIScreen.screenWidth(), height: 80.0)
//        var newFrame = attributes.frame
//        newFrame.size.height = newSize.height
//        newFrame.size.width = newSize.width
//        attributes.frame = newFrame
//        return attributes
//    }

}


