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
    var postChangedNotification: NotificationObserver?

    private var isSetup = false

    @IBOutlet weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var noPostsView: UIView!
    @IBOutlet weak var noPostsHeader: UILabel!
    @IBOutlet weak var noPostsBody: UILabel!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImage: FLAnimatedImageView!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var noPostsViewHeight: NSLayoutConstraint!

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
        postChangedNotification = NotificationObserver(notification: PostChangedNotification) { [unowned self] (post, change) in
            if post.authorId == self.currentUser?.id && change == .Create {
                self.updateNoPostsView(false)
            }
        }
    }

     deinit {
        currentUserChangedNotification?.removeObserver()
        currentUserChangedNotification = nil
        postChangedNotification?.removeObserver()
        postChangedNotification = nil
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        coverImage.alpha = 0
        setupNavigationBar()
        setupNoPosts()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()

        if let handle = currentUser?.atName,
            let userHandle = user?.atName
            where handle == userHandle
        {
            Tracker.sharedTracker.ownProfileViewed(handle)
        }
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if !coverWidthSet {
            coverWidthSet = true
            var height = view.frame.width / ratio
            if navBarsVisible() {
                height += 59.0
            }
            coverImageHeight.constant = max(height - streamViewController.collectionView.contentOffset.y, height)
            coverImageHeightStart = height
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
        let localToken = streamViewController.resetInitialPageLoadingToken()

        streamViewController.streamService.loadUser(
            initialStreamKind.endpoint,
            streamKind: initialStreamKind,
            success: { (user, responseConfig) in
                if !self.streamViewController.isValidInitialPageLoadingToken(localToken) { return }

                self.userLoaded(user, responseConfig: responseConfig)
            },
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
        logPresentingAlert("ProfileViewController")
        presentViewController(alertController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    private func setupNoPosts() {

        var noPostsHeaderText: String
        var noPostsBodyText: String
        if user?.id == currentUser?.id {
            noPostsHeaderText = NSLocalizedString("Welcome to your Profile", comment: "")
            noPostsBodyText = NSLocalizedString("Everything you post lives here!\n\nThis is the place to find everyone you’re following and everyone that’s following you. You’ll find your Loves here too!", comment: "")
        }
        else {
            noPostsHeaderText = NSLocalizedString("Ello is more fun with friends!", comment: "")
            noPostsBodyText = NSLocalizedString("This person hasn't posted yet.\n\nFollow or mention them to help them get started!", comment: "")
        }

        noPostsHeader.text = noPostsHeaderText
        noPostsHeader.font = UIFont.regularBoldFont(18)
        var paragraphStyle = NSMutableParagraphStyle()
        var attrString = NSMutableAttributedString(string: noPostsBodyText)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        paragraphStyle.lineSpacing = 4

        noPostsBody.font = UIFont.typewriterFont(12)
        noPostsBody.attributedText = attrString
    }

    private func setupNavigationBar() {
        navigationController?.navigationBarHidden = true
        navigationBar.items = [elloNavigationItem]
        if !isRootViewController() {
            let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
            self.elloNavigationItem.leftBarButtonItems = [item]
            self.elloNavigationItem.fixNavBarItemPadding()
        }
        addSearchButton()
    }

    private func userLoaded(user: User, responseConfig: ResponseConfig) {
        if self.user == nil {
            Tracker.sharedTracker.profileViewed(user.atName ?? "(no name)")
        }
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
        else if let cover = user.coverImageURL, coverImage = coverImage
        {
            coverImage.pin_setImageFromURL(cover) { result in
                self.coverImage.alpha = 1.0
            }
        }
        var items: [StreamCellItem] = [StreamCellItem(jsonable: user, type: .ProfileHeader)]
        if let posts = user.posts {
            items += StreamCellItemParser().parse(posts, streamKind: streamViewController.streamKind, currentUser: currentUser)
        }
        updateNoPostsView(count(items) < 2)
        // this calls doneLoading when cells are added
        streamViewController.appendUnsizedCellItems(items, withWidth: self.view.frame.width)

        Tracker.sharedTracker.profileLoaded(user.atName ?? "(no name)")
    }

    private func updateNoPostsView(show: Bool) {
        if !isViewLoaded() {
            return
        }

        if show {
            noPostsView.hidden = false
            animate {
                self.noPostsView.alpha = 1
            }
            updateInsets()
            streamViewController.contentInset.bottom = noPostsViewHeight.constant
        }
        else {
            noPostsView.alpha = 0
            noPostsView.hidden = true
            updateInsets()
        }
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
            // this seemingly unecessary nil check is an attempt
            // to guard against crash #6:
            // https://www.crashlytics.com/ello/ios/apps/co.ello.ello/issues/55725749f505b5ccf00cf76d/sessions/55725654012a0001029d613137326264
            if coverImage != nil {
                coverImage.image = cachedImage
                coverImage.alpha = 1.0
            }
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
        let indexPath = NSIndexPath(forItem: 1, inSection: 0)
        if streamViewController.dataSource.isValidIndexPath(indexPath) {
            streamViewController.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
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
