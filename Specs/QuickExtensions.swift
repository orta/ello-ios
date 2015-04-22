//
//  QuickExtensions.swift
//  Ello
//
//  Created by Colin Gray on 4/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick


extension QuickSpec {

    func showController(viewController: UIViewController) -> UIWindow {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.makeKeyAndVisible()
        window.rootViewController = viewController
        return window
    }
}


public extension UIStoryboard {

    class func storyboardWithId(identifier: String, storyboardName: String = "Main") -> UIViewController {
        return UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: AppDelegate.self)).instantiateViewControllerWithIdentifier(identifier) as! UIViewController
    }

}
