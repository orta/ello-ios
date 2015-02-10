//
//  ProfileViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class ProfileViewController: StreamableViewController {

    let user: User
    @IBOutlet weak var logOutButton : UIButton!

    required init(user : User) {
        self.user = user

        super.init(nibName: "ProfileViewController", bundle: nil)

        self.title = user.atName ?? "Profile"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if user.userId == currentUser?.userId {
            setupForCurrentUser()
        }
        else {
            let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
            self.navigationItem.leftBarButtonItem = item
        }

        setupStreamController()
    }

    func setupForCurrentUser() {
        self.logOutButton.hidden = false
        self.navigationController?.navigationBarHidden = true
    }


    @IBAction func logOutTapped(sender: ElloTextButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(AccessManager.Notifications.LoggedOut.rawValue, object: nil)
    }


    private func setupStreamController() {
        let controller = StreamViewController.instantiateFromStoryboard()
        controller.streamKind = .Profile(user: user)

        let streamService = StreamService()
        streamService.loadStream(controller.streamKind.endpoint,
            success: { (streamables) -> () in
                controller.addStreamables(streamables)
                controller.doneLoading()
            }) { (error, statusCode) -> () in
                println("failed to load user (reason: \(error))")
                controller.doneLoading()
        }

        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
    }
}