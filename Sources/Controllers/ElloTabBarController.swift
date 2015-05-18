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

    static let DefaultTab = ElloTab.Stream
}

public class ElloTabBarController: UIViewController, HasAppController {
    public let tabBar = ElloTabBar()
    private var systemLoggedOutObserver: NotificationObserver?

    private var visibleViewController = UIViewController()
    var parentAppController: AppViewController?

    private var _tabBarHidden = false
    public var tabBarHidden: Bool {
        get { return _tabBarHidden }
        set { setTabBarHidden(newValue, animated: false) }
    }

    public private(set) var previousTab: ElloTab = .DefaultTab
    public var selectedTab: ElloTab = .DefaultTab {
        willSet {
            if selectedTab != previousTab {
                previousTab = selectedTab
            }
        }
        didSet {
            updateVisibleViewController()
        }
    }

    public var selectedViewController: UIViewController {
        get { return childViewControllers[selectedTab.rawValue] as! UIViewController }
        set(controller) {
            let index = find(childViewControllers as! [UIViewController], controller)
            selectedTab = index.flatMap { ElloTab(rawValue: $0) } ?? .DefaultTab
        }
    }

    var currentUser : User?
    var profileResponseConfig: ResponseConfig?
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
        tabBar.delegate = self
        modalTransitionStyle = .CrossDissolve

        updateTabBarItems()
        updateVisibleViewController()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        positionTabBar()
        selectedViewController.view.frame = view.bounds
    }

    private func positionTabBar() {
        var upAmount = CGFloat(0)
        if !tabBarHidden {
            upAmount = tabBar.frame.height
        }
        tabBar.frame = view.bounds.fromBottom().withHeight(tabBar.frame.height).shiftUp(upAmount)
    }

    func setTabBarHidden(hidden: Bool, animated: Bool) {
        _tabBarHidden = hidden

        animate(animated: animated) {
            self.positionTabBar()
        }
    }
}

// listen for system logged out event
public extension ElloTabBarController {
    private func setupNotificationObservers() {
        systemLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.invalidToken, block: systemLoggedOut)
    }

    private func removeNotificationObservers() {
        systemLoggedOutObserver?.removeObserver()
    }

}

public extension ElloTabBarController {
    func setProfileData(currentUser: User) {
        self.currentUser = currentUser
        for controller in childViewControllers {
            if let controller = controller as? BaseElloViewController {
                controller.currentUser = currentUser
            }
            else if let controller = controller as? ElloNavigationController {
                controller.setProfileData(currentUser)
            }
        }
    }

    func systemLoggedOut() {
        let alertController = AlertViewController(message: "You have been automatically logged out")

        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
        alertController.addAction(action)

        self.presentViewController(alertController, animated: true, completion: nil)
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
        dispatch_async(dispatch_get_main_queue()) {
            if self.visibleViewController.parentViewController != self {
                self.showViewController(self.childViewControllers[self.selectedTab.rawValue] as! UIViewController)
            }
            else if self.visibleViewController != self.selectedViewController {
                self.transitionControllers(self.visibleViewController, self.selectedViewController)
            }
        }
    }

    func hideViewController(hideViewController: UIViewController) {
        if hideViewController.parentViewController == self {
            hideViewController.view.removeFromSuperview()
        }
    }

    func showViewController(showViewController: UIViewController) {
        tabBar.selectedItem = tabBar.items?[selectedTab.rawValue] as? UITabBarItem
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
