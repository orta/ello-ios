//
//  StreamCommentHeaderCell.swift
//  Ello
//
//  Created by Sean on 1/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class StreamCommentHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var calculatedHeight:CGFloat = 50.0
    
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
}