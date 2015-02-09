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

    override func viewDidLoad() {
        super.viewDidLoad()

        let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
        self.navigationItem.leftBarButtonItem = item

        setupStreamController()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> ProfileViewController {
        return storyboard.controllerWithID(.Profile) as ProfileViewController
    }

    @IBAction func logOutTapped(sender: ElloTextButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(AccessManager.Notifications.LoggedOut.rawValue, object: nil)
    }


    required init(user : User) {
        self.user = user

        super.init(nibName: nil, bundle: nil)

        self.title = user.at_name ?? "Profile"
    }

    private func setupStreamController() {
        let controller = StreamViewController.instantiateFromStoryboard()
        controller.streamKind = .Profile(user: user)

        let streamService = StreamService()
        streamService.loadStream(controller.streamKind.endpoint,
            success: { (streamables) -> () in
                println("success streamable load: \(streamables)")
                controller.addStreamables(streamables)
                controller.doneLoading()
            }) { (error, statusCode) -> () in
                println("failed to load comments")
        }

        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
    }
}