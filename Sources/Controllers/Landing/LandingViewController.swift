//
//  LandingViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class LandingViewController: BaseElloViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signInButton: ElloButton!
    @IBOutlet weak var signUpButton: LightElloButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupNotificationObservers()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        checkIfLoggedIn()
    }

    class func instantiateFromStoryboard() -> LandingViewController {
        return UIStoryboard.storyboardWithId(.Landing) as LandingViewController
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
        profileService.loadCurrentUser({ user in
            var vc = UIStoryboard.storyboardWithId(.ElloTabBar) as ElloTabBarController
            vc.currentUser = user
            self.presentViewController(vc, animated: true, completion: nil)
        }, failure: { error in
            println("error: \(error)")
            self.showButtons()
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
        center.addObserver(self, selector: Selector("loggedOut:"), name: AccessManager.Notifications.LoggedOut.rawValue, object: nil)
        center.addObserver(self, selector: Selector("failedToLoadCurrentUser:"), name: "ElloProviderNotification401", object: nil)
    }

    private func removeNotificationObservers() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }

    func failedToLoadCurrentUser(notification: NSNotification) {
        let authToken = AuthToken()
        authToken.reset()
        showButtons()
    }

    func loggedOut(notification: NSNotification) {
        let authToken = AuthToken()
        authToken.reset()

        self.dismissViewControllerAnimated(true, completion: nil)
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
