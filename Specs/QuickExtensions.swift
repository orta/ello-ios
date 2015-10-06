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
        let frame: CGRect
        let view = viewController.view
        if view.frame.size.width > 0 && view.frame.size.height > 0 {
            frame = CGRect(origin: CGPointZero, size: view.frame.size)
        }
        else {
            frame = UIScreen.mainScreen().bounds
        }
        let window = UIWindow(frame: frame)

        window.makeKeyAndVisible()
        window.rootViewController = viewController
        viewController.view.layoutIfNeeded()
        return window
    }

    func showView(view: UIView) -> UIWindow {
        let controller = UIViewController()
        controller.view.frame.size = view.frame.size
        view.frame.origin = CGPointZero
        controller.view.addSubview(view)
        return showController(controller)
    }
}


public extension UIStoryboard {

    class func storyboardWithId(identifier: String, storyboardName: String = "Main") -> UIViewController {
        return UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: AppDelegate.self)).instantiateViewControllerWithIdentifier(identifier)
    }

}

public func haveRegisteredIdentifier<T: UITableView>(identifier: String) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "\(identifier) should be registered"
        let tableView = try! actualExpression.evaluate() as! UITableView
        tableView.reloadData()
        // Using the side effect of a runtime crash when dequeing a cell here, if it works :thumbsup:
        let _ = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        return true
    }
}

public func beVisibleIn<S: UIView>(view: UIView) -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be visible in \(view)"
        let childView = try! actualExpression.evaluate()
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

public func checkRegions(regions: [OmnibarRegion], contain text: String) {
    for region in regions {
        if let regionText = region.text where regionText.string.contains(text) {
            expect(regionText.string).to(contain(text))
            return
        }
    }
    fail("could not find \(text) in regions \(regions)")
}

public func checkRegions(regions: [OmnibarRegion], notToContain text: String) {
    for region in regions {
        if let regionText = region.text where regionText.string.contains(text) {
            expect(regionText.string).notTo(contain(text))
        }
    }
}

public func checkRegions(regions: [OmnibarRegion], equal text: String) {
    for region in regions {
        if let regionText = region.text where regionText.string == text {
            expect(regionText.string) == text
            return
        }
    }
    fail("could not find \(text) in regions \(regions)")
}

public func haveImageRegion<S: OmnibarScreenProtocol>() -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "have image"

        if let screen = try! actualExpression.evaluate() {
            for region in screen.regions {
                if region.image != nil {
                    return true
                }
            }
        }
        return false
    }
}

public func haveImageRegion<S: OmnibarScreenProtocol>(equal image: UIImage) -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "have image that equals \(image)"

        if let screen = try! actualExpression.evaluate() {
            for region in screen.regions {
                if let regionImage = region.image where regionImage == image {
                    return true
                }
            }
        }
        return false
    }
}

private func allSubviewsIn(view: UIView) -> [UIView] {
    var retVal = [view]
    for subview in view.subviews {
        retVal += allSubviewsIn(subview)
    }
    return retVal
}
