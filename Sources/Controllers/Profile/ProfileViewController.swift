//
//  ProfileViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import FLAnimatedImage

public class ProfileViewController: StreamableViewController {

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.svgItem("person") }
        set { self.tabBarItem = newValue }
    }

    var user: User?
    var responseConfig: ResponseConfig?
    var userParam: String!
    var coverImageHeightStart: CGFloat?
    var coverWidthSet = false
    let ratio:CGFloat = 16.0/9.0
    let initialStreamKind: StreamKind
    var currentUserChangedNotification: NotificationObserver?

    private var isSetup = false

    @IBOutlet weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImage: FLAnimatedImageView!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!

    required public init(userParam: String) {
        self.userParam = userParam
        self.initialStreamKind = .UserStream(userParam: self.userParam)
        super.init(nibName: "ProfileViewController", bundle: nil)

        streamViewController.streamKind = initialStreamKind
        streamViewController.initialLoadClosure = reloadEntireProfile
    }

    // this should only be initialized this way for currentUser in tab nav
    required public init(user: User) {
        // this user should have the .proifle on it since it is currentUser
        self.user = user
        self.userParam = user.id
        self.initialStreamKind = .Profile(perPage: 10)
        super.init(nibName: "ProfileViewController", bundle: nil)

        streamViewController.streamKind = initialStreamKind
        streamViewController.initialLoadClosure = reloadEntireProfile
        currentUserChangedNotification = NotificationObserver(notification: CurrentUserChangedNotification) { [unowned self] _ in
            self.updateCachedImages()
        }
    }

     deinit {
        currentUserChangedNotification?.removeObserver()
        currentUserChangedNotification = nil
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        coverImage.alpha = 0
        setupNavigationBar()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateInsets()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if !coverWidthSet {
            coverWidthSet = true
            coverImageHeight.constant = view.frame.width / ratio
            coverImageHeightStart = coverImageHeight.constant
        }
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override func hideNavBars() {
        super.hideNavBars()
        hideNavBar(animated: true)
        updateInsets()
    }

    private func updateInsets() {
        updateInsets(navBar: navigationBar, streamController: streamViewController)
    }

    private func hideNavBar(#animated: Bool) {
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint, animated: animated)
    }

    // MARK : private

    private func reloadEntireProfile() {
        streamViewController.streamService.loadUser(
            initialStreamKind.endpoint,
            streamKind: initialStreamKind,
            success: userLoaded,
            failure: { (error, statusCode) in
                self.showUserLoadFailure()
                self.streamViewController.doneLoading()
            }
        )
    }

    private func showUserLoadFailure() {
        let message = NSLocalizedString("Something went wrong. Thank you for your patience with Ello Beta!", comment: "Initial stream load failure")
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    private func setupNavigationBar() {
        navigationController?.navigationBarHidden = true
        navigationItem.title = self.title
        navigationBar.items = [navigationItem]
        if !isRootViewController() {
            let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
            self.navigationItem.leftBarButtonItems = [item]
            self.navigationItem.fixNavBarItemPadding()
        }
    }

    private func userLoaded(user: User, responseConfig: ResponseConfig) {
        self.user = user
        updateCurrentUser(user)

        // need to reassign the userParam to the id for paging
        userParam = user.id
        // need to reassign the streamKind so that the currentUser can page based off the user.id from the ElloAPI.path
        // same for when tapping on a username in a post this will replace '~666' with the correct id for paging to work
        streamViewController.streamKind = .UserStream(userParam: userParam)
        streamViewController.responseConfig = responseConfig
        // clear out this view
        streamViewController.clearForInitialLoad()
        title = user.atName ?? "Profile"

        if let cachedImage = cachedImage(.CoverImage) {
            coverImage.image = cachedImage
            self.coverImage.alpha = 1.0
        }
        else if let cover = user.coverImageURL,
            let coverImage = coverImage
        {
            coverImage.sd_setImageWithURL(cover) {
                (image, error, type, url) in
                UIView.animateWithDuration(0.15) {
                    self.coverImage.alpha = 1.0
                }
            }
        }
        var items: [StreamCellItem] = [StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)]
        if let posts = user.posts {
            items += StreamCellItemParser().parse(posts, streamKind: streamViewController.streamKind)
        }
        streamViewController.appendUnsizedCellItems(items, withWidth: self.view.frame.width)
        streamViewController.initialDataLoaded = true
        streamViewController.doneLoading()
    }
}

// MARK: Check for cached coverImage and avatar (only for currentUser)
extension ProfileViewController {
    public func cachedImage(key: CacheKey) -> UIImage? {
        if user?.id == currentUser?.id {
            return TemporaryCache.load(key)
        }
        return nil
    }

    public func updateCachedImages() {
        if let cachedImage = cachedImage(.CoverImage) {
            coverImage.image = cachedImage
            self.coverImage.alpha = 1.0
        }
    }

    public func updateCurrentUser(user: User) {
        if user.id == self.currentUser?.id {
            // only update the avatar and coverImage assets if there is nothing
            // in the cache.  If images are in the cache, that implies that the
            // image could still be unprocessed, so don't set the avatar or
            // coverImage to the old, stale value.
            if cachedImage(.Avatar) == nil {
                self.currentUser?.avatar = user.avatar
            }

            if cachedImage(.CoverImage) == nil {
                self.currentUser?.coverImage = user.coverImage
            }
        }
    }
}

// MARK: ProfileViewController: PostsTappedResponder
extension ProfileViewController: PostsTappedResponder {
    public func onPostsTapped() {
        streamViewController.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
    }
}

// MARK: ProfileViewController: EditProfileResponder
extension ProfileViewController: EditProfileResponder {
    public func onEditProfile() {
        if let settings = UIStoryboard(name: "Settings", bundle: .None).instantiateInitialViewController() as? SettingsContainerViewController {
            settings.currentUser = currentUser
            settings.navBarsVisible = scrollLogic.isShowing
            navigationController?.pushViewController(settings, animated: true)
        }
    }
}

// MARK: ProfileViewController: ViewUsersLovesResponder
extension ProfileViewController: ViewUsersLovesResponder {
    public func onViewUsersLoves() {
        if let user = self.user {
            let vc = LovesViewController(user: user)
            vc.currentUser = self.currentUser
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: ProfileViewController: StreamScrollDelegate
extension ProfileViewController: StreamScrollDelegate {

    override public func streamViewDidScroll(scrollView : UIScrollView) {
        if  let start = coverImageHeightStart,
            let width = coverImage.image?.size.width
        {
            coverImageHeight.constant = max(start - scrollView.contentOffset.y, start)
        }

        super.streamViewDidScroll(scrollView)
    }
}
