//
//  AvatarButton.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class AvatarButton: UIButton {

    func setAvatarURL(url:NSURL?) {
        if let url = url {
            self.sd_setImageWithURL(url, forState: .Normal) { (image, error, type, url) in
                if let image = image {
                    self.alpha = 0
                    UIView.animateWithDuration(0.3,
                        delay:0.0,
                        options:UIViewAnimationOptions.CurveLinear,
                        animations: {
                            self.alpha = 1.0
                    }, completion: nil)
                }
                else if image == nil {
                    self.setDefaultImage()
                }
            }
        }
        else {
            setDefaultImage()
        }
    }

    func setDefaultImage() {
        self.setImage(nil, forState: .Normal)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = self.imageView {
            imageView.layer.cornerRadius = imageView.bounds.size.height / CGFloat(2)
        }
    }

}
