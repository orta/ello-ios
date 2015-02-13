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

//        let profileHeaderCellItem = StreamCellItem(streamable: <#Streamable#>, type: <#StreamCellItem.CellType#>, data: <#Block?#>, oneColumnCellHeight: <#CGFloat#>, multiColumnCellHeight: <#CGFloat#>, isFullWidth: <#Bool#>)
//        streamViewController.addStreamCellItems(self.detailCellItems)

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
        println("got a user: \(user)")
        println("cover image: \(user.coverImageURL)")
        var parser = StreamCellItemParser()
        streamViewController.addUnsizedCellItems(parser.postCellItems(user.posts))
        streamViewController.doneLoading()
    }
}