//
//  CommentIcon.swift
//  Ello
//
//  Created by Sean on 4/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class CommentIcon: UIView, ImageLabelAnimatable {

    public var view: UIView { return self }
    private var _selected = false
    private var _highlighted = false

    public var selected: Bool {
        get { return _selected }
        set {
            _selected = newValue
            if highlighted { return }
            foo(newValue)
        }
    }

    public var highlighted: Bool {
        get { return _highlighted }
        set {
            _highlighted = newValue
            foo(newValue)
        }
    }

    private let duration: CFTimeInterval = 0.5
    private let dotSize = CGSizeMake(3.5, 3.5)
    private let dotSpace: CGFloat = 1.5
    private var dotStart: CGFloat = 0.0
    private var dot1: CAShapeLayer!
    private var dot2: CAShapeLayer!
    private var dot3: CAShapeLayer!

    // MARK: Initializers

    public init() {
        let frame =
        CGRect(
            x: 0,
            y: 0,
            width: 13.5,
            height: 3.5
        )
        super.init(frame: frame)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public func animate() {
        if dot1 != nil { fadeUpDown(dot1, delay: 0.0) }
        if dot2 != nil { fadeUpDown(dot2, delay: 0.25) }
        if dot3 != nil { fadeUpDown(dot3, delay: 0.50) }
    }

    public func finishAnimation() {
        if dot1 != nil { fadeUp(dot1) }
        if dot2 != nil { fadeUp(dot2) }
        if dot3 != nil { fadeUp(dot3) }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        createLayersIfNeeded()
    }

    // MARK: Private

    private func foo(select: Bool) {
        let color:CGColor = select ? UIColor.blackColor().CGColor : UIColor.greyA().CGColor
        if dot1 != nil && dot2 != nil && dot3 != nil {
            dot1.fillColor = color
            dot2.fillColor = color
            dot3.fillColor = color
        }
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
        dot.fillColor = UIColor.greyA().CGColor
        dot.position = CGPoint(x: CGRectGetMinX(inFrame), y: CGRectGetMidY(inFrame))
        dot.opacity = 1.0
        return dot
    }

    private func circlePath(inFrame: CGRect) -> CGPath {
        let circle = UIBezierPath(ovalInRect: inFrame)
        return circle.CGPath
    }
}
