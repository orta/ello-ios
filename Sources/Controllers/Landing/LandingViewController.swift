//
//  LandingViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public class LandingViewController: BaseElloViewController {

    @IBOutlet weak public var scrollView: UIScrollView!
    @IBOutlet weak public var logoView: UIView!
    @IBOutlet weak public var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak public var signInButton: ElloButton!
    @IBOutlet weak public var joinButton: LightElloButton!

    private var userLoggedOutObserver: NotificationObserver?
    private var systemLoggedOutObserver: NotificationObserver?

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

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        checkIfLoggedIn()
    }

    public class func instantiateFromStoryboard() -> LandingViewController {
        return UIStoryboard.storyboardWithId(.Landing) as! LandingViewController
    }

    public func showJoinScreen() {
        let joinController = JoinViewController()
        let window = self.view.window!
        self.removeNotificationObservers()
        self.presentViewController(joinController, animated:true) {
            window.rootViewController = joinController
        }
    }

    public func showSignInScreen() {
        let signInController = SignInViewController()
        let window = self.view.window!
        self.removeNotificationObservers()
        self.presentViewController(signInController, animated:true) {
            window.rootViewController = signInController
        }
    }

    public func showMainScreen(user: User, responseConfig: ResponseConfig) {
        Tracker.sharedTracker.identify(user)
        var vc = ElloTabBarController.instantiateFromStoryboard()
        vc.setProfileData(user, responseConfig: responseConfig)
        var window = self.view.window!
        self.removeNotificationObservers()
        self.presentViewController(vc, animated: true) {
            window.rootViewController = vc
            if let alert = PushNotificationController.sharedController.requestPushAccessIfNeeded() {
                vc.presentViewController(alert, animated: true, completion: .None)
            }
        }
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

        //TODO: Need to get failure back to LandingViewController when loading the current user fails
    }

    private func showButtons() {
        UIView.animateWithDuration(0.2) {
            self.joinButton.alpha = 1.0
            self.signInButton.alpha = 1.0
        }
    }

    private func setupNotificationObservers() {
        userLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.userLoggedOut, block: userLoggedOut)
        systemLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.systemLoggedOut, block: systemLoggedOut)
    }

    private func removeNotificationObservers() {
        userLoggedOutObserver?.removeObserver()
        systemLoggedOutObserver?.removeObserver()
    }

    func failedToLoadCurrentUser() {
        let authToken = AuthToken()
        authToken.reset()
        showButtons()
    }

    func userLoggedOut() {
        let authToken = AuthToken()
        authToken.reset()
        UIApplication.sharedApplication().keyWindow!.rootViewController = self
    }

    func systemLoggedOut() {
        let authToken = AuthToken()
        authToken.reset()

        self.dismissViewControllerAnimated(true, completion: {
            let alertController = AlertViewController(
                message: "You have been automatically logged out")

            let action = AlertAction(title: "OK", style: .Dark, handler: nil)
            alertController.addAction(action)

            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }

}


// MARK: - IBActions
public extension LandingViewController {

    @IBAction func signInTapped(sender: ElloButton) {
        showSignInScreen()
    }

    @IBAction func joinTapped(sender: ElloButton) {
        showJoinScreen()
    }

}
