//
//  ElloLogoView.swift
//  Ello
//
//  Created by Sean on 2/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import QuartzCore
import FLAnimatedImage

class ElloLogoView: FLAnimatedImageView {

    let toValue = (360.0 * M_PI) / 180.0

    func animateLogo() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0.0
        rotate.toValue = self.toValue
        rotate.duration = 0.35
        rotate.repeatCount = 1_000_000
        self.layer.addAnimation(rotate, forKey: "logo-spin")
    }

    func stopAnimatingLogo() {
        let endAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        if let layer = self.layer.presentationLayer() as? CALayer {
            let angle = layer.valueForKeyPath("transform.rotation.z") as NSNumber
            endAnimation.fromValue = angle.floatValue
            endAnimation.toValue = self.toValue
            endAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            endAnimation.duration = 0.25
        }
        self.layer.removeAllAnimations()
        self.layer.addAnimation(endAnimation, forKey: "logo-finish")
    }
}
