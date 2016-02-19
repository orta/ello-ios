//
//  ProfileViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import FLAnimatedImage

public class ElloMentionButton: RoundedElloButton {
    override public func sharedSetup() {
        super.sharedSetup()

        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(UIColor.grey6(), forState: .Highlighted)
        setTitleColor(UIColor.greyC(), forState: .Disabled)
    }

    override func updateOutline() {
        super.updateOutline()
        backgroundColor = highlighted ? UIColor.grey4D() : UIColor.whiteColor()
    }
}


public class ProfileViewController: StreamableViewController {

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.Person) }
        set { self.tabBarItem = newValue }
    }

    var user: User?
    var responseConfig: ResponseConfig?
    var userParam: String!
    var coverImageHeightStart: CGFloat?
    let initialStreamKind: StreamKind
    var currentUserChangedNotification: NotificationObserver?
    var postChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var deeplinkPath: String?
    private var isSetup = false

    @IBOutlet weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var noPostsView: UIView!
    @IBOutlet weak var noPostsHeader: UILabel!
    @IBOutlet weak var noPostsBody: UILabel!

    @IBOutlet weak var coverImage: FLAnimatedImageView!
    @IBOutlet weak var relationshipControl: RelationshipControl!
    @IBOutlet weak var mentionButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var relationshipControlsView: UIView!
    let gradientLayer = CAGradientLayer()

    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var noPostsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var relationshipControlsViewTopConstraint: NSLayoutConstraint!

    required public init(userParam: String) {
        self.userParam = userParam
        self.initialStreamKind = .UserStream(userParam: self.userParam)
        super.init(nibName: "ProfileViewController", bundle: nil)

        streamViewController.streamKind = initialStreamKind
        streamViewController.initialLoadClosure = reloadEntireProfile
        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { [unowned self] user in
            if self.user?.id == user.id {
                self.updateRelationshipPriority(user.relationshipPriority)
            }
        }
    }

    // this should only be initialized this way for currentUser in tab nav
    required public init(user: User) {
        // this user must have the profile property assigned (since it is currentUser)
        self.user = user
        self.userParam = user.id
        self.initialStreamKind = .CurrentUserStream
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
        relationshipChangedNotification?.removeObserver()
        relationshipChangedNotification = nil
    }

    required public init?(coder aDecoder: NSCoder) {
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
        relationshipControl.relationshipDelegate = streamViewController.dataSource.relationshipDelegate
        relationshipControl.style = .ProfileView

        setupGradient()

        if let handle = currentUser?.atName,
            let userHandle = user?.atName
            where handle == userHandle
        {
            Tracker.sharedTracker.ownProfileViewed(handle)
        }

        if let user = user {
            updateCurrentUser(user)
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let ratio: CGFloat = ProfileHeaderCellSizeCalculator.ratio
        let height: CGFloat = view.frame.width / ratio
        let maxHeight = height - streamViewController.collectionView.contentOffset.y
        coverImageHeight.constant = max(maxHeight, height)
        coverImageHeightStart = height

        gradientLayer.frame.size = gradientView.frame.size
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }

        animate {
            self.updateGradientViewConstraint()
            self.relationshipControlsViewTopConstraint.constant = self.navigationBar.frame.height

            self.relationshipControlsView.frame.origin.y = self.relationshipControlsViewTopConstraint.constant
            self.gradientView.frame.origin.y = self.gradientViewTopConstraint.constant
        }
    }

    override func hideNavBars() {
        super.hideNavBars()
        hideNavBar(animated: true)
        updateInsets()

        animate {
            self.updateGradientViewConstraint()
            if self.user?.id == self.currentUser?.id && self.user?.id != nil {
                self.relationshipControlsViewTopConstraint.constant = -self.relationshipControlsView.frame.height
            }
            else {
                self.relationshipControlsViewTopConstraint.constant = 0
            }

            self.relationshipControlsView.frame.origin.y = self.relationshipControlsViewTopConstraint.constant
            self.gradientView.frame.origin.y = self.gradientViewTopConstraint.constant
        }
    }

    private func updateGradientViewConstraint() {
        let scrollView = streamViewController.collectionView
        let additional: CGFloat = navBarsVisible() ? navigationBar.frame.height : 0
        let constant: CGFloat

        if scrollView.contentOffset.y < 0 {
            constant = 0
        }
        else if scrollView.contentOffset.y > 45 {
            constant = -45
        }
        else {
            constant = -scrollView.contentOffset.y
        }
        gradientViewTopConstraint.constant = constant + additional
    }

    private func updateInsets() {
        updateInsets(navBar: relationshipControlsView, streamController: streamViewController)
    }

    private func hideNavBar(animated animated: Bool) {
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
                if let deeplinkPath = self.deeplinkPath,
                    deeplinkURL = NSURL(string: deeplinkPath)
                {
                    UIApplication.sharedApplication().openURL(deeplinkURL)
                    self.deeplinkPath = nil
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {
                    self.showUserLoadFailure()
                }
                self.streamViewController.doneLoading()
            }
        )
    }

    private func showUserLoadFailure() {
        let message = InterfaceString.GenericError
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: InterfaceString.OK, style: .Dark) { _ in
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(action)
        logPresentingAlert("ProfileViewController")
        presentViewController(alertController, animated: true, completion: nil)
    }

    private func setupNoPosts() {

        var noPostsHeaderText: String
        var noPostsBodyText: String
        if user?.id == currentUser?.id {
            noPostsHeaderText = InterfaceString.Profile.CurrentUserNoResultsTitle
            noPostsBodyText = InterfaceString.Profile.CurrentUserNoResultsBody
        }
        else {
            noPostsHeaderText = InterfaceString.Profile.NoResultsTitle
            noPostsBodyText = InterfaceString.Profile.NoResultsBody
        }

        noPostsHeader.text = noPostsHeaderText
        noPostsHeader.font = UIFont.regularBoldFont(18)
        let paragraphStyle = NSMutableParagraphStyle()
        let attrString = NSMutableAttributedString(string: noPostsBodyText)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        paragraphStyle.lineSpacing = 4

        noPostsBody.font = UIFont.defaultFont()
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
        addMoreFollowingButton()
    }

    private func setupGradient() {
        gradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: gradientView.frame.width,
            height: gradientView.frame.height
        )
        gradientLayer.locations = [0, 0.8, 1]
        gradientLayer.colors = [
            UIColor.whiteColor().CGColor,
            UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor,
            UIColor.whiteColor().colorWithAlphaComponent(0).CGColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientView.layer.addSublayer(gradientLayer)
    }

    func addMoreFollowingButton() {
        if let currentUser = currentUser where userParam == currentUser.id || userParam == "~\(currentUser.username)" {
            elloNavigationItem.rightBarButtonItems = []
            return
        }

        guard let user = user else {
            elloNavigationItem.rightBarButtonItems = []
            return
        }

        if let currentUser = currentUser where user.id == currentUser.id {
            elloNavigationItem.rightBarButtonItems = []
            return
        }

        var rightBarButtonItems: [UIBarButtonItem] = []
        if user.hasSharingEnabled {
            rightBarButtonItems.append(UIBarButtonItem(image: .Share, target: self, action: Selector("sharePostTapped")))
        }
        rightBarButtonItems.append(UIBarButtonItem(image: .Dots, target: self, action: Selector("moreButtonTapped")))
        elloNavigationItem.rightBarButtonItems = rightBarButtonItems
    }

    @IBAction func mentionButtonTapped() {
        if let user = user {
            createPost(text: "\(user.atName) ", fromController: self)
        }
    }

    @IBAction func editButtonTapped() {
        onEditProfile()
    }

    @IBAction func inviteButtonTapped() {
        onInviteFriends()
    }

    func moreButtonTapped() {
        if let user = user {
            let userId = user.id
            let userAtName = user.atName
            let relationshipPriority = user.relationshipPriority
            streamViewController.relationshipController?.launchBlockModal(userId, userAtName: userAtName, relationshipPriority: relationshipPriority) { relationshipPriority in
                user.relationshipPriority = relationshipPriority
            }
        }
    }

    func sharePostTapped() {
        if  let user = user,
            let shareLink = user.shareLink,
            let shareURL = NSURL(string: shareLink)
        {
            Tracker.sharedTracker.userShared(user)
            let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: [SafariActivity()])
            if UI_USER_INTERFACE_IDIOM() == .Phone {
                activityVC.modalPresentationStyle = .FullScreen
                logPresentingAlert(readableClassName() ?? "ProfileViewController")
                presentViewController(activityVC, animated: true) { }
            }
            else {
                activityVC.modalPresentationStyle = .Popover
                logPresentingAlert(readableClassName() ?? "ProfileViewController")
                presentViewController(activityVC, animated: true) { }
            }
        }
    }

    private func userLoaded(user: User, responseConfig: ResponseConfig) {
        if self.user == nil {
            Tracker.sharedTracker.profileViewed(user.atName ?? "(no name)")
        }
        self.user = user
        updateCurrentUser(user)

        relationshipControl.userId = user.id
        relationshipControl.userAtName = user.atName
        relationshipControl.relationshipPriority = user.relationshipPriority

        // need to reassign the userParam to the id for paging
        userParam = user.id
        // need to reassign the streamKind so that the currentUser can page based off the user.id from the ElloAPI.path
        // same for when tapping on a username in a post this will replace '~666' with the correct id for paging to work
        streamViewController.streamKind = .UserStream(userParam: userParam)
        streamViewController.responseConfig = responseConfig
        // clear out this view
        streamViewController.clearForInitialLoad()
        title = user.atName ?? InterfaceString.Profile.Title
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
        var items: [StreamCellItem] = [
            StreamCellItem(jsonable: user, type: .ProfileHeader),
            StreamCellItem(jsonable: user, type: .Spacer(height: 54)),
        ]
        if let posts = user.posts {
            items += StreamCellItemParser().parse(posts, streamKind: streamViewController.streamKind, currentUser: currentUser)
        }
        updateNoPostsView(items.count < 2)
        // this calls doneLoading when cells are added
        streamViewController.appendUnsizedCellItems(items, withWidth: self.view.frame.width)

        addMoreFollowingButton()
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

            elloNavigationItem.rightBarButtonItem = nil

            mentionButton.hidden = true
            relationshipControl.hidden = true
            editButton.hidden = false
            inviteButton.hidden = false
        }
        else {
            mentionButton.hidden = false
            relationshipControl.hidden = false
            editButton.hidden = true
            inviteButton.hidden = true
        }
    }

    public func updateRelationshipPriority(relationshipPriority: RelationshipPriority) {
        relationshipControl.relationshipPriority = relationshipPriority
        self.user?.relationshipPriority = relationshipPriority
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
extension ProfileViewController {

    override public func streamViewDidScroll(scrollView : UIScrollView) {
        if let start = coverImageHeightStart {
            coverImageHeight.constant = max(start - scrollView.contentOffset.y, start)
        }

        updateGradientViewConstraint()

        super.streamViewDidScroll(scrollView)
    }
}
