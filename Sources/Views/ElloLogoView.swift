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

private let AngleToValue = 2 * M_PI

public class ElloLogoView: FLAnimatedImageView {
    struct Size {
        static let natural = CGSize(width: 60, height: 60)
        static let big = CGSize(width: 166, height: 166)
    }

    private var wasAnimating = false
    private var shouldReanimate = false

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience public init() {
        self.init(frame: CGRectZero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.image = InterfaceImage.ElloLogo.normalImage
    }

    override public func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        if wasAnimating && newWindow == nil {
            shouldReanimate = true
        }
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && shouldReanimate {
            shouldReanimate = false
            animateLogo()
        }
    }

    func animateLogo() {
        wasAnimating = true

        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0.0
        rotate.toValue = AngleToValue
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
            endAnimation.toValue = AngleToValue
            endAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            endAnimation.duration = 0.25
        }
        self.layer.addAnimation(endAnimation, forKey: "logo-finish")
    }
}
