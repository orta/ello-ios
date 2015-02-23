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
    var coverImageHeightStart: CGFloat?
    var coverWidthSet = false
    let ratio:CGFloat = 16.0/9.0

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var coverImageTopConstraint : NSLayoutConstraint!

    required init(user : User) {
        self.user = user
        self.streamViewController = StreamViewController.instantiateFromStoryboard()
        self.streamViewController.streamKind = .Profile(user: user)
        super.init(nibName: "ProfileViewController", bundle: nil)
        self.title = user.atName ?? "Profile"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        coverImage.alpha = 0
        if user.isCurrentUser {
            // do stuff
        }
        if let viewControllers = self.navigationController?.viewControllers {
            if countElements(viewControllers) > 1 {
                let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
                navigationItem.leftBarButtonItem = item
            }
        }
        setupStreamController()
    }

    @IBAction func logOutTapped(sender: ElloTextButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(AccessManager.Notifications.LoggedOut.rawValue, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !coverWidthSet {
            coverWidthSet = true
            coverImageHeight.constant = view.frame.width / ratio
            coverImageHeightStart = coverImageHeight.constant
        }
    }

    private func setupStreamController() {
        StreamService().loadUser(streamViewController.streamKind.endpoint,
            success: userLoaded,
            failure: { (error, statusCode) in
                println("failed to load user (reason: \(error))")
                self.streamViewController.doneLoading()
            })
        streamViewController.streamScrollDelegate = self
        streamViewController.willMoveToParentViewController(self)
        viewContainer.addSubview(streamViewController.view)
        streamViewController.view.frame = viewContainer.bounds
        streamViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)
    }

    private func userLoaded(user: User) {
        if let cover = user.coverImageURL {
            coverImage.sd_setImageWithURL(cover, completed: {
                (image, error, type, url) in
                UIView.animateWithDuration(0.15, animations: {
                    self.coverImage.alpha = 1.0
                })
            })
        }

        let profileHeaderCellItem = StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 320.0, multiColumnCellHeight: 0.0, isFullWidth: true)
        streamViewController.addStreamCellItems([profileHeaderCellItem])

        var parser = StreamCellItemParser()
        streamViewController.addUnsizedCellItems(parser.postCellItems(user.posts, streamKind: streamViewController.streamKind))
        streamViewController.doneLoading()
    }
}

extension ProfileViewController: StreamScrollDelegate {

    func scrollViewDidScroll(scrollView : UIScrollView) {
        if let (start, width) = unwrap(coverImageHeightStart, coverImage.image?.size.width) {
            coverImageHeight.constant = max(start - scrollView.contentOffset.y, start)
        }
    }
}