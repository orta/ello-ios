//
//  UIButtonExtensions.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension UIButton {

    func setImage(interfaceImage: Interface.Image, imageStyle: Interface.Image.Style, forState state: UIControlState) {
        self.setImage(interfaceImage.image(imageStyle), forState: state)
    }

    func setImages(interfaceImage: Interface.Image, degree: Double = 0, white: Bool = false) {
        if white {
            self.setImage(interfaceImage.whiteImage, forState: .Normal, degree: degree)
        }
        else {
            self.setImage(interfaceImage.normalImage, forState: .Normal, degree: degree)
        }
        self.setImage(interfaceImage.selectedImage, forState: .Selected, degree: degree)
    }

    func setImage(image: UIImage!, forState state: UIControlState = .Normal, degree: Double) {
        self.setImage(image, forState: state)
        if degree != 0 {
            let radians = (degree * M_PI) / 180.0
            transform = CGAffineTransformMakeRotation(CGFloat(radians))
        }
    }
}
