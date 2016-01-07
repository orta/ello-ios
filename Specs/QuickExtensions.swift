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
// import Nimble_Snapshots


func showController(viewController: UIViewController) -> UIWindow {
    let frame: CGRect
    let view = viewController.view
    if view.frame.size.width > 0 && view.frame.size.height > 0 {
        frame = CGRect(origin: CGPointZero, size: view.frame.size)
    }
    else {
        frame = UIScreen.mainScreen().bounds
    }

    if #available(iOS 9.0, *) {
        viewController.loadViewIfNeeded()
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

public enum SnapshotDevice {
    case Pad_Landscape
    case Pad_Portrait
    case Phone4_Portrait
    case Phone5_Portrait
    case Phone6_Portrait
    case Phone6Plus_Portrait

    static let all: [SnapshotDevice] = [
        .Pad_Landscape,
        .Pad_Portrait,
        .Phone4_Portrait,
        .Phone5_Portrait,
        .Phone6_Portrait,
        .Phone6Plus_Portrait,
    ]

    var description: String {
        switch self {
            case Pad_Landscape: return "iPad in Landscape"
            case Pad_Portrait: return "iPad in Portrait"
            case Phone4_Portrait: return "iPhone4 in Portrait"
            case Phone5_Portrait: return "iPhone5 in Portrait"
            case Phone6_Portrait: return "iPhone6 in Portrait"
            case Phone6Plus_Portrait: return "iPhone6Plus in Portrait"
        }
    }

    var size: CGSize {
        switch self {
            case Pad_Landscape: return CGSize(width: 1024, height: 768)
            case Pad_Portrait: return CGSize(width: 768, height: 1024)
            case Phone4_Portrait: return CGSize(width: 320, height: 480)
            case Phone5_Portrait: return CGSize(width: 320, height: 568)
            case Phone6_Portrait: return CGSize(width: 375, height: 667)
            case Phone6Plus_Portrait: return CGSize(width: 414, height: 736)
        }
    }
}

func validateAllSnapshots(subject: Snapshotable, named name: String? = nil, record: Bool = false, file: String = __FILE__, line: UInt = __LINE__) {
    for device in SnapshotDevice.all {
        context(device.description) {
            beforeEach {
                prepareForSnapshot(subject, device: device)
            }
            describe("view") {
                it("should match the screenshot", file: file, line: line) {
                    let localName: String?
                    if let name = name {
                        localName = "\(name) on \(device.description)"
                    }
                    else {
                        localName = nil
                    }
                    expect(subject, file: file, line: line).to(record ? recordSnapshot(named: localName) : haveValidSnapshot(named: localName))
                }
            }
        }
    }
}

func prepareForSnapshot(subject: Snapshotable, device: SnapshotDevice) {
    prepareForSnapshot(subject, size: device.size)
}

func prepareForSnapshot(subject: Snapshotable, size: CGSize) {
    let parent = UIView(frame: CGRect(origin: CGPointZero, size: size))
    let view = subject.snapshotObject!
    view.frame = parent.bounds
    parent.addSubview(view)
    view.layoutIfNeeded()
    showView(view)
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
