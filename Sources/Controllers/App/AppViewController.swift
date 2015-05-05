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
    @IBOutlet weak public var signInButton: ElloButton!
    @IBOutlet weak public var joinButton: LightElloButton!

    var visibleViewController: UIViewController?

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupNotificationObservers()
    }

    deinit {
        removeNotificationObservers()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.view.frame.height < CGFloat(568) {
            logoTopConstraint.constant = 56
        }
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
        return UIStoryboard.storyboardWithId(.Landing) as! AppViewController
    }

// MARK: - Private

    private func setupStyles() {
        scrollView.backgroundColor = UIColor.grey3()
        view.backgroundColor = UIColor.grey3()
        view.setNeedsDisplay()
        joinButton.backgroundColor = UIColor.greyA()
        signInButton.backgroundColor = UIColor.blackColor()
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
        profileService.loadCurrentUser({ (user, responseConfig) in
            self.showMainScreen(user, responseConfig: responseConfig)
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
        }
    }

    private func setupNotificationObservers() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("userLoggedOut:"), name: Notifications.UserLoggedOut.rawValue, object: nil)
        center.addObserver(self, selector: Selector("systemLoggedOut:"), name: Notifications.SystemLoggedOut.rawValue, object: nil)
    }

    private func removeNotificationObservers() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }

}


// MARK: Screens
extension AppViewController {

    public func showJoinScreen() {
        let joinController = JoinViewController()
        joinController.parentAppController = self
        self.swapViewController(joinController)
    }

    public func showSignInScreen() {
        let signInController = SignInViewController()
        signInController.parentAppController = self
        self.swapViewController(signInController)
    }

    public func showMainScreen(user: User, responseConfig: ResponseConfig) {
        Tracker.sharedTracker.identify(user)

        var vc = ElloTabBarController.instantiateFromStoryboard()
        vc.setProfileData(user, responseConfig: responseConfig)
        self.swapViewController(vc) {
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

        self.prepareToShowViewController(newViewController)

        UIView.animateWithDuration(0.2, animations: {
            self.visibleViewController?.view.alpha = 0
            newViewController.view.alpha = 1
            self.scrollView.alpha = 0
        }, completion: { completed in
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
            }, completion: { completed in
                visibleViewController.view.removeFromSuperview()
                visibleViewController.removeFromParentViewController()
                self.visibleViewController = nil
                completion?()
            })
        }
        else {
            showButtons()
            self.scrollView.alpha = 1
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

    @objc
    func userLoggedOut(notification: NSNotification) {
        let authToken = AuthToken()
        authToken.reset()
        removeViewController()
    }

    @objc
    func systemLoggedOut(notification: NSNotification) {
        let authToken = AuthToken()
        authToken.reset()

        removeViewController() {
            let alertController = AlertViewController(
                message: "You have been automatically logged out")

            let action = AlertAction(title: "OK", style: .Dark, handler: nil)
            alertController.addAction(action)

            self.presentViewController(alertController, animated: true, completion: nil)
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
