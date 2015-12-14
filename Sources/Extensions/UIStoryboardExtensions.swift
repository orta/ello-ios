//
//  UIStoryboardExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

public extension UIStoryboard {

    class func storyboardWithId(identifier:StoryboardIdentifier, storyboardName: String = "Main") -> UIViewController {
        return UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: AppDelegate.self)).instantiateViewControllerWithIdentifier(identifier.rawValue) 
    }
}
