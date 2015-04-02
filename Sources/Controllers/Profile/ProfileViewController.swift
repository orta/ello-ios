//
//  ProfileViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import FLAnimatedImage

class ProfileViewController: StreamableViewController, EditProfileResponder {

    var user: User?
    var responseConfig: ResponseConfig?
    let userParam: String
    let streamViewController = StreamViewController.instantiateFromStoryboard()
    var coverImageHeightStart: CGFloat?
    var coverWidthSet = false
    let ratio:CGFloat = 16.0/9.0

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImage: FLAnimatedImageView!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!

    required init(userParam: String) {
        self.userParam = userParam
        self.streamViewController.streamKind = .UserStream(userParam: userParam)
        super.init(nibName: "ProfileViewController", bundle: nil)
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.streamService.loadUser(streamViewController.streamKind.endpoint,
            success: userLoaded,
            failure: { (error, statusCode) in
                println("failed to load user (reason: \(error))")
                self.streamViewController.doneLoading()
            }
        )
    }

    // this should only be initialized this way for currentUser in tab nav
    required init(user: User, responseConfig: ResponseConfig) {
        ElloHUD.showLoadingHudInView(streamViewController.view)
        self.user = user
        self.responseConfig = responseConfig
        self.userParam = self.user!.userId
        self.streamViewController.streamKind = .Profile
        super.init(nibName: "ProfileViewController", bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        if let user = self.user {
            if let responseConfig = self.responseConfig {
                userLoaded(user, responseConfig: responseConfig)
            }
        }
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
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserLoggedOut.rawValue, object: nil)
    }

    func onEditProfile() {
        if let settings = UIStoryboard(name: "Settings", bundle: .None).instantiateInitialViewController() as? SettingsViewController {
            settings.currentUser = currentUser
            navigationController?.pushViewController(settings, animated: true)
        }
    }

// MARK : private

    private func setupStreamController() {
        streamViewController.currentUser = currentUser
        streamViewController.streamScrollDelegate = self
        streamViewController.userTappedDelegate = self
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

    private func userLoaded(user: User, responseConfig: ResponseConfig) {
        self.user = user
        self.streamViewController.responseConfig = responseConfig
        self.streamViewController.infiniteScrollClosure = addAuthorToPosts // TODO: this line can be removed when author is added to posts
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

        var items: [StreamCellItem] = [StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)]
        items += StreamCellItemParser().parse(user.posts, streamKind: streamViewController.streamKind)
        streamViewController.appendUnsizedCellItems(items)
        streamViewController.doneLoading()
    }

    // TODO: this method can be removed when author is added to posts
    private func addAuthorToPosts(jsonables: [JSONAble]) {
        if let user = self.user {
            if let posts = jsonables as? [Post] {
                for post in posts {
                    post.author = user
                }
            }
        }
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
