//
//  UIButtonExtensions.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SVGKit

extension UIButton {

    func setImages(image: Interface.Image, degree: Double = 0, white: Bool = false) {
        if white {
            self.setImage(image.whiteImage, forState: .Normal, degree: degree)
        }
        else {
            self.setImage(image.normalImage, forState: .Normal, degree: degree)
        }
        self.setImage(image.selectedImage, forState: .Selected, degree: degree)
    }

    func setImage(image: UIImage!, forState state: UIControlState = .Normal, degree: Double) {
        self.setImage(image, forState: state)
        if degree != 0 {
            let radians = (degree * M_PI) / 180.0
            transform = CGAffineTransformMakeRotation(CGFloat(radians))
        }
    }
}
