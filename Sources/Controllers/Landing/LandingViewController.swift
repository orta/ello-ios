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
    @IBOutlet weak var requestInviteButton: ElloTextButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        checkIfLoggedIn()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> LandingViewController {
        return storyboard.controllerWithID(.Landing) as LandingViewController
    }

// MARK: - Private

    private func setupStyles() {
        scrollView.backgroundColor = UIColor.elloDarkGray()
        view.backgroundColor = UIColor.elloDarkGray()
        view.setNeedsDisplay()
    }

    private func checkIfLoggedIn() {
        let authToken = AuthToken()
        if authToken.isValid {
            for bundle in NSBundle.allBundles() {
                println(bundle)
            }

            let vc = ElloTabBarController.instantiateFromStoryboard()
            self.presentViewController(vc, animated: true, completion: nil)
        }
        else {
            showSignInButton()
        }
    }

    private func showSignInButton() {
        signInButton.hidden = false
        UIView.animateWithDuration(0.2, animations: {
            self.signInButton.alpha = 1.0
        })
    }

// MARK: - IBActions

    @IBAction func signInTapped(sender: ElloButton) {
        let signInController = SignInViewController.instantiateFromStoryboard()
        self.presentViewController(signInController, animated:true, completion:nil)
    }

    @IBAction func requestInviteTapped(sender: ElloTextButton) {
        let requestInviteController = RequestInviteViewController.instantiateFromStoryboard()
        self.presentViewController(requestInviteController, animated:true, completion:nil)
    }

}
