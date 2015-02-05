//
//  AvatarButton.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class AvatarButton: UIButton {

    weak var userDelegate: UserDelegate?

    func setAvatarURL(url:NSURL) {
        var state = UIControlState.Normal
        self.sd_setImageWithURL(url, forState: state) {
            (image, error, type, url) in
            if error == nil && image != nil {
                let size = self.bounds.size
                self.setImage(image.squareImageToSize(size)?.roundCorners(), forState: state)
            }
            else {
                self.setImage(nil, forState: state)
            }
        }
    }

}
