//
//  ElloTabBarController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

public enum ElloTab: Int {
    case Discovery
    case Notifications
    case Stream
    case Profile
    case Post

    static let DefaultTab = ElloTab.Stream

    public var title: String {
        switch self {
            case Discovery:     return "Discovery"
            case Notifications: return "Notifications"
            case Stream:        return "Stream"
            case Profile:       return "Profile"
            case Post:          return "Omnibar"
        }
    }

    public var narrationDefaultKey: String { return "ElloTabBarControllerDidShowNarration\(title)" }

    public var narrationText: String {
        switch self {
            case Discovery:     return "Find friends, interesting people & amazing content."
            case Notifications: return "Keep up to date with real-time Ello alerts."
            case Stream:        return "Stay organized by following people in Friends or Noise."
            case Profile:       return "Everything you’ve posted in one place."
            case Post:          return "One easy place to post: text, images & gifs!"
        }
    }

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

    var narrationView = NarrationView()
    public var isShowingNarration = false
    public var shouldShowNarration: Bool {
        get { return !ElloTabBarController.didShowNarration(selectedTab) }
        set { ElloTabBarController.didShowNarration(selectedTab, !newValue) }
    }
}

public extension ElloTabBarController {

    class func didShowNarration(tab: ElloTab) -> Bool {
        return Defaults[tab.narrationDefaultKey].bool ?? false
    }

    class func didShowNarration(tab: ElloTab, _ value: Bool) {
        Defaults[tab.narrationDefaultKey] = value
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
        view.opaque = true
        view.addSubview(tabBar)
        tabBar.delegate = self
        modalTransitionStyle = .CrossDissolve

        let gesture = UITapGestureRecognizer(target: self, action: Selector("dismissNarrationView"))
        narrationView.userInteractionEnabled = true
        narrationView.addGestureRecognizer(gesture)

        updateTabBarItems()
        updateVisibleViewController()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateNarrationTitle(animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        positionTabBar()
        selectedViewController.view.frame = view.bounds
    }

    private func positionTabBar() {
        var upAmount = CGFloat(0)
        if !tabBarHidden || isShowingNarration {
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
    public func activateTabBar() {
        setupNotificationObservers()
    }

    public func deactivateTabBar() {
        removeNotificationObservers()
    }

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
        parentAppController?.forceLogOut()
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
        let currentViewController = visibleViewController
        let nextViewController = selectedViewController

        dispatch_async(dispatch_get_main_queue()) {
            if currentViewController.parentViewController != self {
                self.showViewController(nextViewController)
                self.prepareNarration()
            }
            else if currentViewController != nextViewController {
                self.transitionControllers(currentViewController, nextViewController)
            }
        }

        visibleViewController = nextViewController
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
    }

    func transitionControllers(hideViewController: UIViewController, _ showViewController: UIViewController) {
        transitionFromViewController(hideViewController,
            toViewController: showViewController,
            duration: 0,
            options: nil,
            animations: {
                self.hideViewController(hideViewController)
                self.showViewController(showViewController)
            },
            completion: { _ in
                self.prepareNarration()
            })
    }

}

extension ElloTabBarController {

    private func prepareNarration() {
        if shouldShowNarration {
            if !isShowingNarration {
                animateInNarrationView()
            }
            updateNarrationTitle()
        }
        else if isShowingNarration {
            animateOutNarrationView()
        }
    }

    func dismissNarrationView() {
        shouldShowNarration = false
        animateOutNarrationView()
    }

    private func updateNarrationTitle(animated: Bool = true) {
        animate(animated: animated, options: .CurveEaseOut | .BeginFromCurrentState) {
            if let rect = self.tabBar.itemPositionsIn(self.narrationView).safeValue(self.selectedTab.rawValue) {
                self.narrationView.pointerX = rect.midX
            }
        }
        narrationView.text = NSLocalizedString(selectedTab.narrationText, comment: "\(selectedTab.title) narration text")
    }

    private func animateInStartFrame() -> CGRect {
        let upAmount = CGFloat(20)
        let narrationHeight = NarrationView.Size.height
        let pointerHeight = NarrationView.Size.pointer.height
        let bottomMargin = ElloTabBar.Size.height - NarrationView.Size.pointer.height
        return CGRect(
            x: 0,
            y: view.frame.height - bottomMargin - narrationHeight - upAmount,
            width: view.frame.width,
            height: narrationHeight
            )
    }

    private func animateInFinalFrame() -> CGRect {
        let narrationHeight = NarrationView.Size.height
        let pointerHeight = NarrationView.Size.pointer.height
        let bottomMargin = ElloTabBar.Size.height - NarrationView.Size.pointer.height
        return CGRect(
            x: 0,
            y: view.frame.height - bottomMargin - narrationHeight,
            width: view.frame.width,
            height: narrationHeight
            )
    }

    private func animateInNarrationView() {
        let narrationHeight = NarrationView.Size.height
        let pointerHeight = NarrationView.Size.pointer.height
        let bottomMargin = ElloTabBar.Size.height - NarrationView.Size.pointer.height

        narrationView.alpha = 0
        narrationView.frame = animateInStartFrame()
        view.addSubview(narrationView)
        updateNarrationTitle(animated: false)
        animate() {
            self.narrationView.alpha = 1
            self.narrationView.frame = self.animateInFinalFrame()
        }
        isShowingNarration = true
    }

    private func animateOutNarrationView() {
        animate() {
            self.narrationView.alpha = 0
            self.narrationView.frame = self.animateInStartFrame()
        }
        isShowingNarration = false
    }

}
