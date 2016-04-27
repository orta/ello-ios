//
//  ElloLogoView.swift
//  Ello
//
//  Created by Sean on 2/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import QuartzCore
import FLAnimatedImage
import CoreGraphics

public class ElloLogoView: UIImageView {
    struct Size {
        static let natural = CGSize(width: 60, height: 60)
        static let big = CGSize(width: 166, height: 166)
    }

    private var wasAnimating = false

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience public init() {
        self.init(frame: CGRectZero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.image = InterfaceImage.ElloLogo.normalImage
        self.contentMode = .ScaleAspectFit
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && wasAnimating {
            animateLogo()
        }
    }

    func animateLogo() {
        wasAnimating = true

        self.layer.removeAnimationForKey("logo-spin")
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        let angle = layer.valueForKeyPath("transform.rotation.z") as! NSNumber
        rotate.fromValue = angle
        rotate.toValue = 2 * M_PI
        rotate.duration = 0.35
        rotate.repeatCount = 1_000_000
        self.layer.addAnimation(rotate, forKey: "logo-spin")
    }

    func stopAnimatingLogo() {
        wasAnimating = false

        self.layer.removeAllAnimations()

        let endAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        if let layer = self.layer.presentationLayer() as? CALayer {
            let angle = layer.valueForKeyPath("transform.rotation.z") as! NSNumber
            endAnimation.fromValue = angle.floatValue
            endAnimation.toValue = 0
            endAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            endAnimation.duration = 0.25
        }
        self.layer.addAnimation(endAnimation, forKey: "logo-spin")
    }
}
