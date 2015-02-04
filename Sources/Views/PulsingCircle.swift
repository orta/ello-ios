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
    
    func stopPulse() {
        if let circle = circle {
            circle.layer.removeAllAnimations()
        }
    }

    func pulse() {

        if circle == nil {
            circle = UIView(frame: self.bounds)
            circle!.layer.cornerRadius = self.bounds.width/2
            circle!.backgroundColor = UIColor.elloLightGray()
            circle!.clipsToBounds = true
            self.addSubview(circle!)
        }

        UIView.animateWithDuration(0.65,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.circle!.transform = CGAffineTransformMakeScale(0.8, 0.8)
            },
            completion: { done in
                if done {
                    UIView.animateWithDuration(0.65,
                        delay: 0.0,
                        options: UIViewAnimationOptions.CurveEaseOut,
                        animations: {
                            self.circle!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                        },
                        completion: { finished in
                            if finished {
                                self.pulse()
                            }
                    })

                }
        })
        
    }
}