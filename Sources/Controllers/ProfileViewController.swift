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
    let streamViewController: StreamViewController
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var coverImage: UIImageView!

    required init(user : User) {
        self.user = user
        self.streamViewController = StreamViewController.instantiateFromStoryboard()
        self.streamViewController.streamKind = .Profile(user: user)

        super.init(nibName: "ProfileViewController", bundle: nil)

        self.title = user.atName ?? "Profile"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if user.isCurrentUser {
            // do stuff
        }

        let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
        navigationItem.leftBarButtonItem = item

        setupStreamController()
    }

    @IBAction func logOutTapped(sender: ElloTextButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(AccessManager.Notifications.LoggedOut.rawValue, object: nil)
    }


    private func setupStreamController() {
        StreamService().loadUser(streamViewController.streamKind.endpoint,
            success: userLoaded,
            failure: { (error, statusCode) in
                println("failed to load user (reason: \(error))")
                self.streamViewController.doneLoading()
            })

        streamViewController.willMoveToParentViewController(self)
        viewContainer.addSubview(streamViewController.view)
        streamViewController.view.frame = viewContainer.bounds
        streamViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)
    }

    private func userLoaded(user: User) {
        if let cover = user.coverImageURL {
            coverImage.sd_setImageWithURL(cover)
        }
        
        let profileHeaderCellItem = StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 320.0, multiColumnCellHeight: 0.0, isFullWidth: true)
        streamViewController.addStreamCellItems([profileHeaderCellItem])

        var parser = StreamCellItemParser()
        streamViewController.addUnsizedCellItems(parser.postCellItems(user.posts))
        streamViewController.doneLoading()
    }
}