//
//  UIStoryboardExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public extension UIStoryboard {

    class func iPhone() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle:nil)
    }

    public func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewControllerWithIdentifier(identifier.rawValue) as UIViewController
    }
}

