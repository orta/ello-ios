//
//  ProfileViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class ProfileViewController: StreamableViewController, EditProfileResponder {

    let userParam: String
    let streamViewController: StreamViewController
    var coverImageHeightStart: CGFloat?
    var coverWidthSet = false
    let ratio:CGFloat = 16.0/9.0

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!

    required init(userParam: String) {
        self.userParam = userParam
        self.streamViewController = StreamViewController.instantiateFromStoryboard()
        self.streamViewController.streamKind = .Profile(userParam: userParam)
        super.init(nibName: "ProfileViewController", bundle: nil)
        self.streamViewController.userTappedDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        coverImage.alpha = 0
        if isRootViewController() {
            hideNavBar()
        }
        setupStreamController()
        setupNavigationBar()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !coverWidthSet {
            coverWidthSet = true
            coverImageHeight.constant = view.frame.width / ratio
            coverImageHeightStart = coverImageHeight.constant
        }
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        if !isRootViewController() {
            showNavBar()
        }

        if scrollToBottom {
            if let scrollView = streamViewController.collectionView {
                let contentOffsetY : CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
                if contentOffsetY > 0 {
                    scrollView.scrollEnabled = false
                    scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
                    scrollView.scrollEnabled = true
                }
            }
        }
    }

    func showNavBar() {
        navigationBarTopConstraint.constant = 0
        self.view.layoutIfNeeded()
    }

    override func hideNavBars() {
        super.hideNavBars()
        hideNavBar()
    }

    func hideNavBar() {
        navigationBarTopConstraint.constant = navigationBar.frame.height + 1
        self.view.layoutIfNeeded()
    }

    @IBAction func logOutTapped(sender: ElloTextButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(AccessManager.Notifications.LoggedOut.rawValue, object: nil)
    }

    func editProfile() {
        if let settings = UIStoryboard(name: "Settings", bundle: .None).instantiateInitialViewController() as? SettingsViewController {
            navigationController?.pushViewController(settings, animated: true)
        }
    }

    private func setupStreamController() {
        streamViewController.streamService.loadUser(streamViewController.streamKind.endpoint,
            success: userLoaded,
            failure: { (error, statusCode) in
                println("failed to load user (reason: \(error))")
                self.streamViewController.doneLoading()
            })
        streamViewController.currentUser = currentUser
        streamViewController.streamScrollDelegate = self
        streamViewController.willMoveToParentViewController(self)
        viewContainer.addSubview(streamViewController.view)
        streamViewController.view.frame = viewContainer.bounds
        streamViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBarHidden = true
        navigationItem.title = self.title
        navigationBar.items = [navigationItem]
        if !isRootViewController() {
            let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
            self.navigationItem.leftBarButtonItems = [item]
            self.navigationItem.fixNavBarItemPadding()
        }
    }

    private func userLoaded(user: User) {
        if !isRootViewController() {
            self.title = user.atName ?? "Profile"
        }
        if let cover = user.coverImageURL {
            coverImage.sd_setImageWithURL(cover, completed: {
                (image, error, type, url) in
                UIView.animateWithDuration(0.15, animations: {
                    self.coverImage.alpha = 1.0
                })
            })
        }

        let profileHeaderCellItem = StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 340.0, multiColumnCellHeight: 0.0, isFullWidth: true)
        streamViewController.appendStreamCellItems([profileHeaderCellItem])
        streamViewController.appendUnsizedCellItems(StreamCellItemParser().parse(user.posts, streamKind: streamViewController.streamKind))
        streamViewController.doneLoading()
    }
}

// MARK: ProfileViewController: StreamScrollDelegate
extension ProfileViewController: StreamScrollDelegate {

    override func streamViewDidScroll(scrollView : UIScrollView) {
        if let (start, width) = unwrap(coverImageHeightStart, coverImage.image?.size.width) {
            coverImageHeight.constant = max(start - scrollView.contentOffset.y, start)
        }
        super.streamViewDidScroll(scrollView)
    }
}
