//
//  CommentButton.swift
//  Ello
//
//  Created by Sean on 2/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import QuartzCore

class CommentButton: StreamFooterButton {

    let duration:CFTimeInterval = 0.5
    private var dot1: CAShapeLayer!
    private var dot2: CAShapeLayer!
    private var dot3: CAShapeLayer!
    let dotSize = CGSizeMake(3.5, 3.5)
    let dotSpace:CGFloat = 1.5
    let dotStart:CGFloat = 10.0

    override var selected: Bool {
        didSet {
            let color:CGColor = selected ? UIColor.blackColor().CGColor : UIColor.elloLightGray().CGColor
            dot1.fillColor = color
            dot2.fillColor = color
            dot3.fillColor = color
        }
    }

    override init() {
        super.init()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleEdgeInsets = UIEdgeInsetsMake(0, self.dotStart + 15.0, 0, 0);
        createLayersIfNeeded()
    }

    private func fadeUpDown(dot:CAShapeLayer, delay: NSTimeInterval) {
        let dotFadeUpOpacity = CABasicAnimation(keyPath: "opacity")
        dotFadeUpOpacity.toValue = 1.0

        let dotFadeDownOpacity = CABasicAnimation(keyPath: "opacity")
        dotFadeDownOpacity.toValue = 0.0

        let group = CAAnimationGroup()
        group.duration = 0.5
        group.repeatCount = 1_000_000
        group.autoreverses = true
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        group.beginTime = CACurrentMediaTime() + delay
        group.animations = [dotFadeUpOpacity, dotFadeDownOpacity]
        dot.addAnimation(group, forKey: "Show fill circle \(dot)")
    }

    func animate() {
        fadeUpDown(dot1, delay: 0.0)
        fadeUpDown(dot2, delay: 0.25)
        fadeUpDown(dot3, delay: 0.50)
    }

    func finishAnimation() {
        fadeUp(dot1)
        fadeUp(dot2)
        fadeUp(dot3)
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        return CGSizeMake(size.width + self.dotStart, size.height)
    }

    private func fadeUp(dot:CAShapeLayer) {
        dot.removeAllAnimations()
        let up = CABasicAnimation(keyPath: "opacity")
        up.toValue = 1.0
        up.duration = duration
        dot.addAnimation(up, forKey: "up")
    }

    private func createLayersIfNeeded() {
        if dot1 == nil {
            dot1 = circleShape(CGRectMake(dotStart, self.bounds.height/2  - dotSize.height/2, dotSize.width, dotSize.height))
            self.layer.addSublayer(dot1)
        }

        if dot2 == nil {
            dot2 = circleShape(CGRectMake(dotStart + dotSize.width + dotSpace, self.bounds.height/2  - dotSize.height/2, dotSize.width, dotSize.height))
            self.layer.addSublayer(dot2)
        }

        if dot3 == nil {
            dot3 = circleShape(CGRectMake(dotStart + dotSize.width * 2 + dotSpace * 2, self.bounds.height/2  - dotSize.height/2, dotSize.width, dotSize.height))
            self.layer.addSublayer(dot3)
        }
    }

    private func circleShape(inFrame: CGRect) -> CAShapeLayer {
        let dot = CAShapeLayer()
        dot.path = circlePath(inFrame)
        dot.bounds = CGPathGetBoundingBox(dot.path)
        dot.fillColor = UIColor.elloLightGray().CGColor
        dot.position = CGPoint(x: CGRectGetMinX(inFrame), y: CGRectGetMinY(inFrame))
        dot.opacity = 1.0
        return dot
    }

    private func circlePath(inFrame: CGRect) -> CGPath {
        let circle = UIBezierPath(ovalInRect: inFrame)
        return circle.CGPath
    }
    
}