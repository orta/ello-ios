//
//  ElloTabBarController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public class ElloTabBarController: UIViewController {
    private var visibleViewController: UIViewController? = nil
    private var tabBar: ElloTabBar
    // stores the actual value (used by the tabBarHidden property *and* setTabBarHidden func)
    private var tabBarHiddenValue: Bool

    // calls setTabBarHidden(animated: false)
    var tabBarHidden: Bool {
        get { return tabBarHiddenValue }
        set { setTabBarHidden(newValue, animated: false) }
    }

    var selectedIndex: Int {
        didSet {
            if count(childViewControllers) == 0 {
                // no controllers? only allow 0 index
                if selectedIndex != 0 {
                    selectedIndex = 0
                }
            }
            else if selectedIndex < 0 {
                selectedIndex = 0
            }
            else if selectedIndex < count(childViewControllers) {
                updateVisibleViewController()
                if let selectedViewController = selectedViewController {
                    if tabBar.selectedItem != selectedViewController.tabBarItem {
                        tabBar.selectedItem = selectedViewController.tabBarItem
                    }
                }
            }
            else {
                selectedIndex = count(childViewControllers) - 1
            }
        }
    }

    public var selectedViewController: UIViewController? {
        get {
            if selectedIndex >= 0 && selectedIndex < count(childViewControllers) {
                return childViewControllers[selectedIndex] as? UIViewController
            }
            return nil
        }
        set(controller) {
            if let controller = controller {
                if let index = find(childViewControllers as! [UIViewController], controller) {
                    // this will call updateVisibleViewController()
                    selectedIndex = index
                }
            }
        }
    }

    var currentUser : User?
    var profileResponseConfig: ResponseConfig?

    public class func instantiateFromStoryboard() -> ElloTabBarController {
        return UIStoryboard.storyboardWithId(.ElloTabBar) as! ElloTabBarController
    }

    required public init(coder decoder: NSCoder) {
        selectedIndex = decoder.decodeIntegerForKey("selectedIndex")
        tabBarHiddenValue = false
        tabBar = ElloTabBar()
        super.init(coder: decoder)
    }

    func setProfileData(currentUser: User, responseConfig: ResponseConfig) {
        self.currentUser = currentUser
        self.profileResponseConfig = responseConfig
        for controller in self.childViewControllers {
            if let controller = controller as? BaseElloViewController {
                controller.currentUser = currentUser
            }
            else if let controller = controller as? ElloNavigationController {
                controller.setProfileData(currentUser, responseConfig: responseConfig)
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tabBar)
        tabBar.delegate = self

        selectedIndex = 2
        updateTabBarItems()
        modalTransitionStyle = .CrossDissolve
        if let selectedViewController = selectedViewController {
            tabBar.selectedItem = selectedViewController.tabBarItem
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var upAmount = CGFloat(0)
        if !tabBarHiddenValue {
            upAmount = self.tabBar.frame.height
        }
        tabBar.frame = self.view.bounds.fromBottom().withHeight(self.tabBar.frame.height).shiftUp(upAmount)

        if let selectedViewController = selectedViewController {
            selectedViewController.view.frame = self.view.bounds
            if !tabBarHiddenValue {
                selectedViewController.view.frame = selectedViewController.view.frame.shrinkUp(tabBar.frame.height)
            }
        }
    }

    func setTabBarHidden(hidden: Bool, animated: Bool) {
        tabBarHiddenValue = hidden

        let animations:()->() = {
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
        if let items = tabBar.items as? [UITabBarItem] {
            if let index = find(items, item) {
                if index == selectedIndex {
                    if let navigationViewController = selectedViewController as? UINavigationController {
                        navigationViewController.popToRootViewControllerAnimated(true)
                    }
                }
                else {
                    selectedIndex = index
                }
            }
        }
    }

}


// MARK: Child View Controller handling
extension ElloTabBarController {

    override public func addChildViewController(childController: UIViewController) {
        super.addChildViewController(childController)

        if visibleViewController == nil {
            selectedIndex = 0
        }
        updateTabBarItems()
    }

    private func updateTabBarItems() {
        let controllers = self.childViewControllers as! [UIViewController]
        let mapper : (UIViewController)->UITabBarItem = { controller in
            let tabBarItem = controller.tabBarItem
            if tabBarItem.selectedImage.renderingMode != .AlwaysOriginal {
                tabBarItem.selectedImage = tabBarItem.selectedImage.imageWithRenderingMode(.AlwaysOriginal)
            }
            return tabBarItem
        }
        let items = controllers.map(mapper)
        tabBar.items = items
    }

    private func updateVisibleViewController() {
        if let prevController = visibleViewController {
            if let selectedViewController = selectedViewController {
                if prevController != selectedViewController {
                    transitionControllers(prevController, selectedViewController)
                }
            }
            else {
                hideViewController(prevController)
            }
        }
        else if let selectedViewController = selectedViewController {
            showViewController(selectedViewController)
        }

        visibleViewController = selectedViewController
    }

    private func hideViewController(hideViewController: UIViewController) {
        if hideViewController.parentViewController == self {
            hideViewController.view.removeFromSuperview()
        }
    }

    private func showViewController(showViewController: UIViewController) {
        self.view.insertSubview(showViewController.view, belowSubview: tabBar)
        showViewController.view.frame = tabBar.frame.fromBottom().growUp(self.view.frame.height - tabBar.frame.height)
        showViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    }

    private func transitionControllers(hideViewController: UIViewController, _ showViewController: UIViewController) {
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

    override public func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize size: CGSize) -> CGSize {
        return self.view.frame.size
    }

}
