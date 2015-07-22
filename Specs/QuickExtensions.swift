//
//  QuickExtensions.swift
//  Ello
//
//  Created by Colin Gray on 4/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


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

public func haveRegisteredIdentifier<T: UITableView>(identifier: String) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "\(identifier) should be registered"
        let tableView = actualExpression.evaluate() as! UITableView
        tableView.reloadData()
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? UITableViewCell
        return cell != nil
    }
}

public func beVisibleIn<S: UIView>(view: UIView) -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be visible in \(view)"
        let childView = actualExpression.evaluate()
        if let childView = childView {
            if childView.hidden || childView.alpha < 0.01 || childView.frame.size.width < 0.1 || childView.frame.size.height < 0.1 {
                return false
            }

            var parentView: UIView? = childView.superview
            while parentView != nil {
                if let parentView = parentView where parentView == view {
                    return true
                }
                parentView = parentView!.superview
            }
        }
        return false
    }
}

private func allSubviewsIn(view: UIView) -> [UIView] {
    var retVal = [view]
    for subview in view.subviews {
        retVal += allSubviewsIn(subview as! UIView)
    }
    return retVal
}
