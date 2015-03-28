//
//  UIStoryboardExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

extension UIStoryboard {

    class func storyboardWithId(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: NSBundle(forClass: AppDelegate.self)).instantiateViewControllerWithIdentifier(identifier.rawValue) as! UIViewController
    }
}

