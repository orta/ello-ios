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
    @IBOutlet weak public var signInButton: ElloButton!
    @IBOutlet weak public var signUpButton: LightElloButton!

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupNotificationObservers()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        checkIfLoggedIn()
    }

    public class func instantiateFromStoryboard() -> LandingViewController {
        return UIStoryboard.storyboardWithId(.Landing) as! LandingViewController
    }

// MARK: - Private

    private func setupStyles() {
        scrollView.backgroundColor = UIColor.grey3()
        view.backgroundColor = UIColor.grey3()
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
        profileService.loadCurrentUser({ (user, responseConfig) in
            Tracker.sharedTracker.identify(user)
            var vc = UIStoryboard.storyboardWithId(.ElloTabBar) as! ElloTabBarController
            vc.setProfileData(user, responseConfig: responseConfig)
            self.presentViewController(vc, animated: true, completion: nil)
        }, failure: { error in
            self.failedToLoadCurrentUser()
        })

        //TODO: Need to get failure back to LandingViewController when loading the current user fails
        // Currently "ElloProviderNotification401" is posted but that doesn't feel right here
    }

    private func showButtons() {
        signInButton.hidden = false
        signInButton.enabled = true
        UIView.animateWithDuration(0.2, animations: {
            self.signInButton.alpha = 1.0
        })
    }

    private func setupNotificationObservers() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("userLoggedOut:"), name: Notifications.UserLoggedOut.rawValue, object: nil)
        center.addObserver(self, selector: Selector("systemLoggedOut:"), name: Notifications.SystemLoggedOut.rawValue, object: nil)
        center.addObserver(self, selector: Selector("failedToLoadCurrentUser"), name: "ElloProviderNotification401", object: nil)
    }

    private func removeNotificationObservers() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }

    func failedToLoadCurrentUser() {
        let authToken = AuthToken()
        authToken.reset()
        showButtons()
    }

    func userLoggedOut(notification: NSNotification) {
        let authToken = AuthToken()
        authToken.reset()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func systemLoggedOut(notification: NSNotification) {
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

// MARK: - IBActions

    @IBAction func signInTapped(sender: ElloButton) {
        let signInController = SignInViewController()
        self.presentViewController(signInController, animated:true, completion:nil)
    }

    @IBAction func signUpTapped(sender: ElloButton) {
        let createAccountController = CreateAccountViewController.instantiateFromStoryboard()
        self.presentViewController(createAccountController, animated:true, completion:nil)
    }
}
