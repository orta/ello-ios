//
//  ElloTabBarController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public enum ElloTab: Int {
    case Discovery
    case Notifications
    case Stream
    case Profile
    case Post
}

public class ElloTabBarController: UIViewController, HasAppController {
    public private(set) var tabBar: ElloTabBar

    private var visibleViewController = UIViewController()
    var parentAppController: AppViewController?

    private var _tabBarHidden: Bool
    public var tabBarHidden: Bool {
        get { return _tabBarHidden }
        set { setTabBarHidden(newValue, animated: false) }
    }

    public var selectedTab: ElloTab = .Stream {
        didSet {
            updateVisibleViewController()
            tabBar.selectedItem = selectedViewController.tabBarItem
        }
    }

    public var selectedViewController: UIViewController {
        get { return childViewControllers[selectedTab.rawValue] as! UIViewController }
        set(controller) {
            if let index = find(childViewControllers as! [UIViewController], controller) {
                selectedTab = ElloTab(rawValue: index) ?? .Stream
            }
        }
    }

    var currentUser : User?
    var profileResponseConfig: ResponseConfig?

    private var userLoggedOutObserver: NotificationObserver?
    private var systemLoggedOutObserver: NotificationObserver?
    private var receivedPushNotificationObserver: NotificationObserver?

    required public init(coder aDecoder: NSCoder) {
        _tabBarHidden = false
        tabBar = ElloTabBar()

        super.init(coder: aDecoder)

        receivedPushNotificationObserver = NotificationObserver(notification: PushNotificationNotifications.interactedWithPushNotification) { _ in
            self.selectedTab = .Notifications
        }
    }

    deinit {
        receivedPushNotificationObserver?.removeObserver()
    }

}

public extension ElloTabBarController {
    class func instantiateFromStoryboard() -> ElloTabBarController {
        return UIStoryboard.storyboardWithId(.ElloTabBar) as! ElloTabBarController
    }
}

// MARK: View Lifecycle
public extension ElloTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tabBar)
        showViewController(childViewControllers[ElloTab.Stream.rawValue] as! UIViewController)
        tabBar.delegate = self

        updateTabBarItems()
        selectedTab = .Stream
        modalTransitionStyle = .CrossDissolve
        tabBar.selectedItem = selectedViewController.tabBarItem
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var upAmount = CGFloat(0)
        if !tabBarHidden {
            upAmount = tabBar.frame.height
        }
        tabBar.frame = view.bounds.fromBottom().withHeight(tabBar.frame.height).shiftUp(upAmount)

        selectedViewController.view.frame = view.bounds
        if !tabBarHidden {
            selectedViewController.view.frame = selectedViewController.view.frame.shrinkUp(tabBar.frame.height)
        }
    }
}

public extension ElloTabBarController {
    func setProfileData(currentUser: User, responseConfig: ResponseConfig) {
        self.currentUser = currentUser
        self.profileResponseConfig = responseConfig
        for controller in childViewControllers {
            if let controller = controller as? BaseElloViewController {
                controller.currentUser = currentUser
            }
            else if let controller = controller as? ElloNavigationController {
                controller.setProfileData(currentUser, responseConfig: responseConfig)
            }
        }
    }

    func setTabBarHidden(hidden: Bool, animated: Bool) {
        _tabBarHidden = hidden

        let animations: ElloEmptyCompletion = {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animateWithDuration(0.2, animations: animations)
        }
        else {
            animations()
        }
    }
}

// UITabBarDelegate
extension ElloTabBarController: UITabBarDelegate {
    public func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if let items = tabBar.items as? [UITabBarItem], index = find(items, item) {
            if index == selectedTab.rawValue {
                if let navigationViewController = selectedViewController as? UINavigationController {
                    navigationViewController.popToRootViewControllerAnimated(true)
                }
            }
            else {
                selectedTab = ElloTab(rawValue:index) ?? .Stream
            }
        }
    }
}

// MARK: Child View Controller handling
public extension ElloTabBarController {
    override func addChildViewController(childController: UIViewController) {
        super.addChildViewController(childController)
        updateTabBarItems()
    }

    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize size: CGSize) -> CGSize {
        return view.frame.size
    }
}

private extension ElloTabBarController {
    func updateTabBarItems() {
        let controllers = childViewControllers as! [UIViewController]
        tabBar.items = controllers.map { controller in
            let tabBarItem = controller.tabBarItem
            if tabBarItem.selectedImage != nil && tabBarItem.selectedImage.renderingMode != .AlwaysOriginal {
                tabBarItem.selectedImage = tabBarItem.selectedImage.imageWithRenderingMode(.AlwaysOriginal)
            }
            return tabBarItem
        }
    }

    func updateVisibleViewController() {
        if visibleViewController != selectedViewController {
            transitionControllers(visibleViewController, selectedViewController)
        }
    }

    func hideViewController(hideViewController: UIViewController) {
        if hideViewController.parentViewController == self {
            hideViewController.view.removeFromSuperview()
        }
    }

    func showViewController(showViewController: UIViewController) {
        let controller = (showViewController as? UINavigationController)?.topViewController ?? showViewController
        Tracker.sharedTracker.screenAppeared(controller.title ?? controller.readableClassName())
        view.insertSubview(showViewController.view, belowSubview: tabBar)
        showViewController.view.frame = tabBar.frame.fromBottom().growUp(view.frame.height - tabBar.frame.height)
        showViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        visibleViewController = showViewController
    }

    func transitionControllers(hideViewController: UIViewController, _ showViewController: UIViewController) {
        transitionFromViewController(hideViewController,
            toViewController: showViewController,
            duration: 0,
            options: UIViewAnimationOptions(0),
            animations: {
                self.hideViewController(hideViewController)
                self.showViewController(showViewController)
            },
            completion: nil)
    }
}
