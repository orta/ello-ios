//
//  PulsingCircle.swift
//  Ello
//
//  Created by Sean on 2/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import QuartzCore

class PulsingCircle: UIView {

    private var circle:UIView?

    class func fill(view : UIView) -> PulsingCircle {
        var circle = PulsingCircle(frame: view.bounds)
        circle.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        return circle
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && circle != nil {
            circle = nil
            pulse()
        }
    }

    func stopPulse(completion: ((Bool)->())? = nil) {
        self.userInteractionEnabled = false
        if let circle = circle {
            self.circle = nil
            UIView.animateWithDuration(0.65,
                delay: 0.0,
                options: .CurveEaseOut,
                animations: {
                    circle.alpha = 0
                },
                completion: completion
            )
        }
    }

    func pulse() {
        self.userInteractionEnabled = true

        if self.circle == nil {
            var size : CGFloat = 60
            circle = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            circle!.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
            circle!.autoresizingMask = .FlexibleTopMargin | .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin
            circle!.layer.cornerRadius = size / 2
            circle!.backgroundColor = UIColor.elloLightGray()
            circle!.clipsToBounds = true
            self.addSubview(circle!)

            self.keepPulsing(circle!)
        }
    }

    private func keepPulsing(circle : UIView) {
        UIView.animateWithDuration(0.65,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: {
                self.alpha = 1
                circle.transform = CGAffineTransformMakeScale(0.8, 0.8)
            },
            completion: { done in
                if done {
                    UIView.animateWithDuration(0.65,
                        delay: 0.0,
                        options: .CurveEaseOut,
                        animations: {
                            circle.transform = CGAffineTransformMakeScale(1.0, 1.0)
                        },
                        completion: { finished in
                            if finished && self.circle != nil {
                                self.keepPulsing(circle)
                            }
                        }
                    )
                }
        })
    }
}