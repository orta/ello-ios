//
//  AppViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit


@objc
protocol HasAppController {
    var parentAppController: AppViewController? { get set }
}


public class AppViewController: BaseElloViewController {

    @IBOutlet weak public var scrollView: UIScrollView!
    @IBOutlet weak public var logoView: UIView!
    @IBOutlet weak public var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak public var socialRevolution: UILabel!
    @IBOutlet weak public var signInButton: LightElloButton!
    @IBOutlet weak public var joinButton: ElloButton!

    var visibleViewController: UIViewController?
    private var userLoggedOutObserver: NotificationObserver?
    private var receivedPushNotificationObserver: NotificationObserver?

    private var pushPayload: PushPayload?

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
        setupStyles()
    }

    deinit {
        removeNotificationObservers()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if view.frame.height - logoView.frame.maxY < 250 {
            let top = view.frame.height - 250 - logoView.frame.height
            logoTopConstraint.constant = top
        }
        scrollView.contentSize = view.frame.size
    }

    var isStartup = true
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if isStartup {
            isStartup = false
            checkIfLoggedIn()
        }
    }

    public class func instantiateFromStoryboard() -> AppViewController {
        return UIStoryboard.storyboardWithId(.App) as! AppViewController
    }

// MARK: - Private

    private func setupStyles() {
        scrollView.backgroundColor = .whiteColor()
        view.backgroundColor = .whiteColor()
        view.setNeedsDisplay()
    }

    private func checkIfLoggedIn() {
        let authToken = AuthToken()
        if authToken.isPresent {
            self.loadCurrentUser()
        }
        else {
            self.showButtons()
        }
    }

    public func loadCurrentUser(failure: ElloErrorCompletion? = nil) {
        let profileService = ProfileService()
        profileService.loadCurrentUser(ElloAPI.Profile(perPage: 1),
            success: { user in
                self.currentUser = user
                self.showMainScreen(user)
            },
            failure: { (error, _) in
                self.failedToLoadCurrentUser(failure, error: error)
            },
            invalidToken: { error in
                self.failedToLoadCurrentUser(failure, error: error)
            })
    }

    func failedToLoadCurrentUser(failure: ElloErrorCompletion?, error: NSError) {
        let authToken = AuthToken()
        authToken.reset()
        showButtons()
    }

    private func showButtons(animated: Bool = true) {
        animate(animated: animated) {
            self.joinButton.alpha = 1.0
            self.signInButton.alpha = 1.0
            self.socialRevolution.alpha = 1.0
        }
    }

    private func hideButtons() {
        self.joinButton.alpha = 0.0
        self.signInButton.alpha = 0.0
        self.socialRevolution.alpha = 0.0
    }

    private func setupNotificationObservers() {
        userLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.userLoggedOut, block: userLoggedOut)
        receivedPushNotificationObserver = NotificationObserver(notification: PushNotificationNotifications.interactedWithPushNotification, block: receivedPushNotification)
    }

    private func removeNotificationObservers() {
        userLoggedOutObserver?.removeObserver()
        receivedPushNotificationObserver?.removeObserver()
    }

}


// MARK: Screens
extension AppViewController {

    public func showJoinScreen() {
        pushPayload = .None
        let joinController = JoinViewController()
        joinController.parentAppController = self
        swapViewController(joinController)
    }

    public func showSignInScreen() {
        pushPayload = .None
        let signInController = SignInViewController()
        signInController.parentAppController = self
        swapViewController(signInController)
    }

    public func showOnboardingScreen(user: User) {
        currentUser = user

        let vc = OnboardingViewController()
        vc.parentAppController = self
        vc.currentUser = user
        self.presentViewController(vc, animated: true, completion: nil)
    }

    public func doneOnboarding() {
        dismissViewControllerAnimated(true, completion: nil)
        self.showMainScreen(currentUser!)
    }

    public func showMainScreen(user: User) {
        Tracker.sharedTracker.identify(user)

        var vc = ElloTabBarController.instantiateFromStoryboard()
        vc.setProfileData(user)
        if let payload = pushPayload {
            navigateToDeepLink(payload.applicationTarget)
            pushPayload = .None
        }

        swapViewController(vc) {
            vc.activateTabBar()
            if let alert = PushNotificationController.sharedController.requestPushAccessIfNeeded() {
                vc.presentViewController(alert, animated: true, completion: .None)
            }
        }
    }

}


// MARK: Screen transitions
extension AppViewController {

    public func swapViewController(newViewController: UIViewController, completion: ElloEmptyCompletion? = nil) {
        newViewController.view.alpha = 0

        visibleViewController?.willMoveToParentViewController(nil)
        newViewController.willMoveToParentViewController(self)

        prepareToShowViewController(newViewController)

        if let tabBarController = visibleViewController as? ElloTabBarController {
            tabBarController.deactivateTabBar()
        }

        UIView.animateWithDuration(0.2, animations: {
            self.visibleViewController?.view.alpha = 0
            newViewController.view.alpha = 1
            self.scrollView.alpha = 0
        }, completion: { _ in
            self.visibleViewController?.view.removeFromSuperview()
            self.visibleViewController?.removeFromParentViewController()

            self.addChildViewController(newViewController)
            if let childController = newViewController as? HasAppController {
                childController.parentAppController = self
            }

            newViewController.didMoveToParentViewController(self)

            self.hideButtons()
            self.visibleViewController = newViewController
            completion?()
        })
    }

    public func removeViewController(completion: ElloEmptyCompletion? = nil) {
        if let visibleViewController = visibleViewController {
            visibleViewController.willMoveToParentViewController(nil)

            if let tabBarController = visibleViewController as? ElloTabBarController {
                tabBarController.deactivateTabBar()
            }

            UIView.animateWithDuration(0.2, animations: {
                self.showButtons(animated: false)
                visibleViewController.view.alpha = 0
                self.scrollView.alpha = 1
            }, completion: { _ in
                visibleViewController.view.removeFromSuperview()
                visibleViewController.removeFromParentViewController()
                self.visibleViewController = nil
                completion?()
            })
        }
        else {
            showButtons()
            scrollView.alpha = 1
            completion?()
        }
    }

    private func prepareToShowViewController(newViewController: UIViewController) {
        let controller = (newViewController as? UINavigationController)?.topViewController ?? newViewController
        Tracker.sharedTracker.screenAppeared(controller.title ?? controller.readableClassName())

        view.addSubview(newViewController.view)
        newViewController.view.frame = self.view.bounds
        newViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    }

}


// MARK: Logout events
public extension AppViewController {
    func userLoggedOut() {
        if isLoggedIn() {
            logOutCurrentUser()
            removeViewController()
        }
    }

    public func forceLogOut() {
        if isLoggedIn() {
            logOutCurrentUser()

            removeViewController() {
                let message = NSLocalizedString("You have been automatically logged out", comment: "Automatically logged out message")
                let alertController = AlertViewController(message: message)

                let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
                alertController.addAction(action)

                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    func isLoggedIn() -> Bool {
        if let visibleViewController = visibleViewController
        where visibleViewController is ElloTabBarController
        {
            return true
        }
        return false
    }

    private func logOutCurrentUser() {
        PushNotificationController.sharedController.deregisterStoredToken()
        AuthToken().reset()
        currentUser = nil
    }
}

// MARK: Push Notification Handling
extension AppViewController {
    func receivedPushNotification(payload: PushPayload) {
        if let vc = self.visibleViewController as? ElloTabBarController {
            navigateToDeepLink(payload.applicationTarget)
        } else {
            self.pushPayload = payload
        }
    }
}

// MARK: URL Handling
extension AppViewController {
    func navigateToDeepLink(path: String) {
        let vc = self.visibleViewController as? ElloTabBarController
        switch path.pathComponents.first ?? "" {
        case "stream":
            vc?.selectedTab = .Stream
        case "notifications":
            vc?.selectedTab = .Notifications
        default:
            break
        }
    }
}


// MARK: - IBActions
public extension AppViewController {

    @IBAction func signInTapped(sender: ElloButton) {
        showSignInScreen()
    }

    @IBAction func joinTapped(sender: ElloButton) {
        showJoinScreen()
    }

}
