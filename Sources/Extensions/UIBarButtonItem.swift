//
//  UIBarButtonItem.swift
//  Ello
//
//  Created by Sean on 1/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension UIBarButtonItem {

    class func backChevronWithTarget(target:AnyObject, action:Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 0, y: 0, width: 36.0, height: 44.0)
        let button = UIButton(frame: frame)
        button.setImage(.AngleBracket, imageStyle: .Normal, forState: .Normal)
        // rotate 180 degrees to flip
        button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)

        return UIBarButtonItem(customView: button)
    }
}
