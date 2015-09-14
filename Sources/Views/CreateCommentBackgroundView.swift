//
//  CreateCommentBackgroundView.swift
//  Ello
//
//  Created by Colin Gray on 3/10/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class CreateCommentBackgroundView : UIView {

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.clearColor()
    }

    override public func drawRect(rect : CGRect) {
        let color = UIColor.blackColor()
        let margin = CGFloat(10)
        let midY = self.frame.height / CGFloat(2)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(0, midY))
        bezierPath.addLineToPoint(CGPointMake(margin, midY - margin))
        bezierPath.addLineToPoint(CGPointMake(margin, 0))
        bezierPath.addLineToPoint(CGPointMake(self.frame.width, 0))
        bezierPath.addLineToPoint(CGPointMake(self.frame.width, self.frame.height))
        bezierPath.addLineToPoint(CGPointMake(margin, self.frame.height))
        bezierPath.addLineToPoint(CGPointMake(margin, midY + margin))
        bezierPath.closePath()
        color.setFill()
        bezierPath.fill()
    }
}