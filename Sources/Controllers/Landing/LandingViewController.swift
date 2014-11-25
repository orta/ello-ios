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

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> LandingViewController {
        return storyboard.controllerWithID(.Landing) as LandingViewController
    }

// MARK: - Private

    private func setupStyles() {
        self.scrollView.backgroundColor = UIColor.elloDarkGray()
        self.view.backgroundColor = UIColor.elloDarkGray()
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
