//
//  UIBarButtonItem.swift
//  Ello
//
//  Created by Sean on 1/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

extension UIBarButtonItem {

    class func backChevronWithTarget(target:AnyObject, action:Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 20, y: 0, width: 29.0, height: 44.0)
        let button = UIButton(frame: frame)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        let image = UIImage(named: "chevron-back-icon")
        button.setImage(image, forState: .Normal)
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        
        return UIBarButtonItem(customView: button)
    }
}