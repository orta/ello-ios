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
    private var systemLoggedOutObserver: NotificationObserver?
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
        if authToken.isValid {
            self.loadCurrentUser()
        }
        else {
            let authService = AuthService()
            authService.reAuthenticate({
                self.loadCurrentUser()
            },
            failure: { (_,_) in
                self.showButtons()
            })
        }
    }

    private func loadCurrentUser() {
        let profileService = ProfileService()
        profileService.loadCurrentUser(ElloAPI.Profile(perPage: 1), success: { user in
            // <restore later>
            // self.showMainScreen(user)
            // </restore later>
            // <debugging code>
            let vc = OnboardingViewController()
            vc.currentUser = user
            self.swapViewController(vc)
            // </debugging code>
        }, failure: { error in
            self.failedToLoadCurrentUser()
        })

        //TODO: Need to get failure back to AppViewController when loading the current user fails
    }

    func failedToLoadCurrentUser() {
        let authToken = AuthToken()
        authToken.reset()
        showButtons()
    }

    private func showButtons() {
        UIView.animateWithDuration(0.2) {
            self.joinButton.alpha = 1.0
            self.signInButton.alpha = 1.0
            self.socialRevolution.alpha = 1.0
        }
    }

    private func setupNotificationObservers() {
        userLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.userLoggedOut, block: userLoggedOut)
        systemLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.systemLoggedOut, block: systemLoggedOut)
        receivedPushNotificationObserver = NotificationObserver(notification: PushNotificationNotifications.interactedWithPushNotification, block: receivedPushNotification)
    }

    private func removeNotificationObservers() {
        userLoggedOutObserver?.removeObserver()
        systemLoggedOutObserver?.removeObserver()
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

    public func showMainScreen(user: User) {
        Tracker.sharedTracker.identify(user)

        var vc = ElloTabBarController.instantiateFromStoryboard()
        vc.setProfileData(user)
        if let payload = pushPayload {
            vc.selectedTab = .Notifications
            pushPayload = .None
        }

        swapViewController(vc) {
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

            self.visibleViewController = newViewController
            completion?()
        })
    }

    public func removeViewController(completion: ElloEmptyCompletion? = nil) {
        if let visibleViewController = visibleViewController {
            visibleViewController.willMoveToParentViewController(nil)

            UIView.animateWithDuration(0.2, animations: {
                self.showButtons()
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
extension AppViewController {
    func userLoggedOut() {
        logOutCurrentUser()
        removeViewController()
    }

    func systemLoggedOut() {
        logOutCurrentUser()
        removeViewController() {
            let alertController = AlertViewController(
                message: "You have been automatically logged out")

            let action = AlertAction(title: "OK", style: .Dark, handler: nil)
            alertController.addAction(action)

            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    private func logOutCurrentUser() {
        PushNotificationController.sharedController.deregisterStoredToken()
        AuthToken().reset()
    }
}

// MARK: Push Notification Handling
extension AppViewController {
    func receivedPushNotification(payload: PushPayload) {
        if let vc = self.visibleViewController as? ElloTabBarController {
            vc.selectedTab = .Notifications
        } else {
            self.pushPayload = payload
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
