//
//  StreamViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation
import UIKit
import SSPullToRefresh
import FLAnimatedImage
import Crashlytics

// MARK: Delegate Implementations
public protocol InviteDelegate: NSObjectProtocol {
    func sendInvite(person: LocalPerson, didUpdate: ElloEmptyCompletion)
}

public protocol SimpleStreamDelegate: NSObjectProtocol {
    func showSimpleStream(endpoint: ElloAPI, title: String, noResultsMessages: (title: String, body: String)?)
}

public protocol StreamImageCellDelegate : NSObjectProtocol {
    func imageTapped(imageView: FLAnimatedImageView, cell: StreamImageCell)
}

@objc
public protocol StreamScrollDelegate: NSObjectProtocol {
    func streamViewDidScroll(scrollView : UIScrollView)
    optional func streamViewWillBeginDragging(scrollView: UIScrollView)
    optional func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

public protocol UserDelegate: NSObjectProtocol {
    func userTappedAvatar(cell: UICollectionViewCell)
    func userTappedText(cell: UICollectionViewCell)
    func userTappedParam(param: String)
}

public protocol WebLinkDelegate: NSObjectProtocol {
    func webLinkTapped(type: ElloURI, data: String)
}

// MARK: StreamNotification
public struct StreamNotification {
    static let AnimateCellHeightNotification = TypedNotification<StreamImageCell>(name: "AnimateCellHeightNotification")
    static let UpdateCellHeightNotification = TypedNotification<UICollectionViewCell>(name: "UpdateCellHeightNotification")
}

// MARK: StreamViewController
public class StreamViewController: BaseElloViewController {

    @IBOutlet weak public var collectionView: UICollectionView!
    @IBOutlet weak public var noResultsLabel: UILabel!
    @IBOutlet weak public var noResultsTopConstraint: NSLayoutConstraint!
    private let defaultNoResultsTopConstant: CGFloat = 113
    var canLoadNext = false
    var streamables:[Streamable]?

    public var noResultsMessages = (title: "", body: "") {
        didSet {
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.lineSpacing = 17

            let titleAttributes = [
                NSFontAttributeName : UIFont.regularBoldFont(18.0),
                NSForegroundColorAttributeName : UIColor.blackColor(),
                NSParagraphStyleAttributeName : titleParagraphStyle
            ]

            let bodyParagraphStyle = NSMutableParagraphStyle()
            bodyParagraphStyle.lineSpacing = 8

            let bodyAttributes = [
                NSFontAttributeName : UIFont.typewriterFont(12.0),
                NSForegroundColorAttributeName : UIColor.blackColor(),
                NSParagraphStyleAttributeName : bodyParagraphStyle
            ]

            let title = NSAttributedString(string: self.noResultsMessages.title + "\n", attributes:titleAttributes)
            let body = NSAttributedString(string: self.noResultsMessages.body, attributes:bodyAttributes)
            self.noResultsLabel.attributedText = title.append(body)
        }
    }

    public var dataSource:StreamDataSource!
    public var postbarController:PostbarController?
    var relationshipController: RelationshipController?
    public var responseConfig: ResponseConfig?
    public let streamService = StreamService()
    public var pullToRefreshView: SSPullToRefreshView?
    var allOlderPagesLoaded = false
    var initialDataLoaded = false
    var parentTabBarController: ElloTabBarController? {
        if  let parentViewController = self.parentViewController,
            let elloController = parentViewController as? BaseElloViewController
        {
            return elloController.elloTabBarController
        }
        return nil
    }

    public var streamKind: StreamKind = StreamKind.Unknown {
        didSet {
            dataSource.streamKind = streamKind
            setupCollectionViewLayout()
        }
    }
    var imageViewer: StreamImageViewer?
    var updatedStreamImageCellHeightNotification: NotificationObserver?
    var updateCellHeightNotification: NotificationObserver?
    var rotationNotification: NotificationObserver?
    var sizeChangedNotification: NotificationObserver?
    var commentChangedNotification: NotificationObserver?
    var postChangedNotification: NotificationObserver?
    var loveChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var settingChangedNotification: NotificationObserver?
    var currentUserChangedNotification: NotificationObserver?

    weak var createPostDelegate : CreatePostDelegate?
    weak var postTappedDelegate : PostTappedDelegate?
    weak var userTappedDelegate : UserTappedDelegate?
    weak var streamScrollDelegate : StreamScrollDelegate?
    var notificationDelegate:NotificationDelegate? {
        get { return dataSource.notificationDelegate }
        set { dataSource.notificationDelegate = newValue }
    }

    var streamFilter:StreamDataSource.StreamFilter {
        get { return dataSource.streamFilter }
        set {
            dataSource.streamFilter = newValue
            collectionView.reloadData()
            self.scrollToTop()
        }
    }

    public var contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            self.collectionView.contentInset = contentInset
            self.collectionView.scrollIndicatorInsets = contentInset
            self.pullToRefreshView?.defaultContentInset = contentInset
        }
    }

    var pullToRefreshEnabled: Bool = true {
        didSet { pullToRefreshView?.hidden = !pullToRefreshEnabled }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }

    override public func didSetCurrentUser() {
        dataSource.currentUser = currentUser

        if let postbarController = postbarController {
            postbarController.currentUser = currentUser
        }

        super.didSetCurrentUser()
    }

    // If we ever create an init() method that doesn't use nib/storyboards,
    // we'll need to call this.  Called from awakeFromNib and init.
    private func initialSetup() {
        setupDataSource()
        setupImageViewDelegate()
        addNotificationObservers()
    }

    deinit {
        removeNotificationObservers()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        pullToRefreshView = SSPullToRefreshView(scrollView: collectionView, delegate: self)
        pullToRefreshView?.contentView = ElloPullToRefreshView(frame:CGRectZero)
        pullToRefreshView?.hidden = !pullToRefreshEnabled

        setupCollectionView()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Crashlytics.sharedInstance().setObjectValue(streamKind.name, forKey: CrashlyticsKey.StreamName.rawValue)
    }

    public class func instantiateFromStoryboard() -> StreamViewController {
        return UIStoryboard.storyboardWithId(.Stream) as! StreamViewController
    }

// MARK: Public Functions

    public func scrollToTop() {
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
    }

    public func doneLoading() {
        ElloHUD.hideLoadingHudInView(view)
        pullToRefreshView?.finishLoading()
        initialDataLoaded = true
        updateNoResultsLabel()
    }

    public func reloadCells() {
        collectionView.reloadData()
    }

    public func removeAllCellItems() {
        dataSource.removeAllCellItems()
        collectionView.reloadData()
    }

    public func imageCellHeightUpdated(cell: StreamImageCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            updateCellHeight(indexPath, height: cell.calculatedHeight)
        }
    }

    public func appendStreamCellItems(items: [StreamCellItem]) {
        dataSource.appendStreamCellItems(items)
        collectionView.reloadData()
    }

    public func appendUnsizedCellItems(items: [StreamCellItem], withWidth: CGFloat?, completion: StreamDataSource.StreamContentReady? = nil) {
        let width = withWidth ?? self.view.frame.width
        dataSource.appendUnsizedCellItems(items, withWidth: width) { indexPaths in
            self.collectionView.reloadData()
            self.doneLoading()
            completion?(indexPaths: indexPaths)
        }
    }

    public func insertUnsizedCellItems(cellItems: [StreamCellItem], startingIndexPath: NSIndexPath, completion: ElloEmptyCompletion? = nil) {
        dataSource.insertUnsizedCellItems(cellItems, withWidth: self.view.frame.width, startingIndexPath: startingIndexPath) { _ in
            self.collectionView.reloadData()
            completion?()
        }
    }

    public var loadInitialPageLoadingToken: String = ""
    public func resetInitialPageLoadingToken() -> String {
        let newToken = NSUUID().UUIDString
        loadInitialPageLoadingToken = newToken
        return newToken
    }
    public func isValidInitialPageLoadingToken(token: String) -> Bool {
        return loadInitialPageLoadingToken == token
    }

    public func cancelInitialPage() {
        resetInitialPageLoadingToken()
        self.doneLoading()
    }

    public var initialLoadClosure: ElloEmptyCompletion?

    public func loadInitialPage() {

        if let initialLoadClosure = initialLoadClosure {
            initialLoadClosure()
        }
        else {
            let localToken = resetInitialPageLoadingToken()

            streamService.loadStream(
                streamKind.endpoint,
                streamKind: streamKind,
                success: { (jsonables, responseConfig) in
                    if !self.isValidInitialPageLoadingToken(localToken) { return }
                    self.clearForInitialLoad()
                    self.responseConfig = responseConfig
                    // this calls doneLoading when cells are added
                    self.appendUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: self.streamKind, currentUser: self.currentUser), withWidth: nil)
                }, failure: { (error, statusCode) in
                    print("failed to load \(self.streamKind.name) stream (reason: \(error))")
                    self.initialLoadFailure()
                    self.doneLoading()
                }, noContent: {
                    print("nothing new")
                    self.doneLoading()
                }
            )
        }
    }

    private func updateNoResultsLabel() {
        delay(0.666) {
            if self.noResultsLabel != nil {
                self.dataSource.visibleCellItems.count > 0 ? self.hideNoResults() : self.showNoResults()
            }
        }
    }

    public func hideNoResults() {
        noResultsLabel.hidden = true
        noResultsLabel.alpha = 0
    }

    public func showNoResults() {
        noResultsLabel.hidden = false
        UIView.animateWithDuration(0.25) {
            self.noResultsLabel.alpha = 1
        }
    }

    public func clearForInitialLoad() {
        allOlderPagesLoaded = false
        dataSource.removeAllCellItems()
        collectionView.reloadData()
    }

// MARK: Private Functions

    private func initialLoadFailure() {
        var isVisible = false
        var view: UIView? = self.view
        while view != nil {
            if view is UIWindow {
                isVisible = true
                break
            }

            view = view!.superview
        }

        if isVisible {
            let message = NSLocalizedString("Something went wrong. Thank you for your patience with Ello Beta!", comment: "Initial stream load failure")
            let alertController = AlertViewController(message: message)
            let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
            alertController.addAction(action)
            logPresentingAlert("StreamViewController")
            presentViewController(alertController, animated: true) {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        else {
            navigationController?.popViewControllerAnimated(false)
        }
    }

    private func addNotificationObservers() {
        updatedStreamImageCellHeightNotification = NotificationObserver(notification: StreamNotification.AnimateCellHeightNotification) { [unowned self] streamImageCell in
            self.imageCellHeightUpdated(streamImageCell)
        }
        updateCellHeightNotification = NotificationObserver(notification: StreamNotification.UpdateCellHeightNotification) { [unowned self] streamTextCell in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
        rotationNotification = NotificationObserver(notification: Application.Notifications.DidChangeStatusBarOrientation) { [unowned self] _ in
            self.collectionView.reloadData()
        }
        sizeChangedNotification = NotificationObserver(notification: Application.Notifications.ViewSizeDidChange) { [unowned self] _ in
            self.collectionView.reloadData()
        }

        commentChangedNotification = NotificationObserver(notification: CommentChangedNotification) { [unowned self] (comment, change) in
            if !self.initialDataLoaded {
                return
            }
            switch change {
            case .Create, .Delete, .Update, .Replaced:
                self.dataSource.modifyItems(comment, change: change, collectionView: self.collectionView)
            default: break
            }
            self.updateNoResultsLabel()
        }

        postChangedNotification = NotificationObserver(notification: PostChangedNotification) { [unowned self] (post, change) in
            if !self.initialDataLoaded {
                return
            }
            switch change {
            case .Delete:
                switch self.streamKind {
                case .PostDetail: break
                default:
                    self.dataSource.modifyItems(post, change: change, collectionView: self.collectionView)
                }
                // reload page
            case .Create,
                .Update,
                .Replaced,
                .Loved:
                self.dataSource.modifyItems(post, change: change, collectionView: self.collectionView)
            case .Read: break
            }
            self.updateNoResultsLabel()
        }

        loveChangedNotification  = NotificationObserver(notification: LoveChangedNotification) { [unowned self] (love, change) in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyItems(love, change: change, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { [unowned self] user in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyUserRelationshipItems(user, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }

        settingChangedNotification = NotificationObserver(notification: SettingChangedNotification) { [unowned self] user in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyUserSettingsItems(user, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }

        currentUserChangedNotification = NotificationObserver(notification: CurrentUserChangedNotification) { [unowned self] user in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyItems(user, change: .Update, collectionView: self.collectionView)
            self.updateNoResultsLabel()
        }
    }

    private func removeNotificationObservers() {
        updatedStreamImageCellHeightNotification?.removeObserver()
        updateCellHeightNotification?.removeObserver()
        rotationNotification?.removeObserver()
        sizeChangedNotification?.removeObserver()
        commentChangedNotification?.removeObserver()
        postChangedNotification?.removeObserver()
        relationshipChangedNotification?.removeObserver()
        loveChangedNotification?.removeObserver()
        settingChangedNotification?.removeObserver()
        currentUserChangedNotification?.removeObserver()
    }

    private func updateCellHeight(indexPath:NSIndexPath, height:CGFloat) {
        let existingHeight = dataSource.heightForIndexPath(indexPath, numberOfColumns: streamKind.columnCount)
        if height != existingHeight {
            collectionView.performBatchUpdates({
                self.dataSource.updateHeightForIndexPath(indexPath, height: height)
            }, completion: nil)
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
        collectionView.directionalLockEnabled = true
        collectionView.keyboardDismissMode = .OnDrag
        StreamCellType.registerAll(collectionView)
        setupCollectionViewLayout()
    }

    // this gets reset whenever the streamKind changes
    private func setupCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? StreamCollectionViewLayout {
            layout.columnCount = streamKind.columnCount
            layout.sectionInset = UIEdgeInsetsZero
            layout.minimumColumnSpacing = 12
            layout.minimumInteritemSpacing = 0
        }
    }

    private func setupImageViewDelegate() {
        if imageViewer == nil {
            imageViewer = StreamImageViewer(presentingController: self)
        }
    }

    private func setupDataSource() {
        let webView = UIWebView(frame: view.bounds)
        dataSource = StreamDataSource(streamKind: streamKind,
            textSizeCalculator: StreamTextCellSizeCalculator(webView: UIWebView(frame: webView.frame)),
            notificationSizeCalculator: StreamNotificationCellSizeCalculator(webView: UIWebView(frame: webView.frame)),
            profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator(webView: UIWebView(frame: webView.frame)),
            imageSizeCalculator: StreamImageCellSizeCalculator())

        dataSource.streamCollapsedFilter = { item in
            if !item.type.collapsable {
                return true
            }
            if let _ = item.jsonable as? Post {
                return item.state != .Collapsed
            }
            return true
        }

        let postbarController = PostbarController(collectionView: collectionView, dataSource: dataSource, presentingController: self)
        postbarController.currentUser = currentUser
        dataSource.postbarDelegate = postbarController
        self.postbarController = postbarController

        relationshipController = RelationshipController(presentingController: self)
        dataSource.relationshipDelegate = relationshipController

        // set delegates
        dataSource.imageDelegate = self
        dataSource.inviteDelegate = self
        dataSource.simpleStreamDelegate = self
        dataSource.userDelegate = self
        dataSource.webLinkDelegate = self

        collectionView.dataSource = dataSource
    }

}

// MARK: DELEGATE EXTENSIONS
// MARK: StreamViewController: InviteDelegate
extension StreamViewController: InviteDelegate {

    public func sendInvite(person: LocalPerson, didUpdate: ElloEmptyCompletion) {
        if let email = person.emails.first {
            Tracker.sharedTracker.friendInvited()
            ElloHUD.showLoadingHudInView(view)
            InviteService().invite(email,
                success: {
                    ElloHUD.hideLoadingHudInView(self.view)
                    didUpdate()
                },
                failure: { _ in
                    ElloHUD.hideLoadingHudInView(self.view)
                    didUpdate()
                }
            )
        }
    }
}

// MARK: StreamViewController: SimpleStreamDelegate
extension StreamViewController: SimpleStreamDelegate {
    public func showSimpleStream(endpoint: ElloAPI, title: String, noResultsMessages: (title: String, body: String)? = nil ) {
        let vc = SimpleStreamViewController(endpoint: endpoint, title: title)
        vc.currentUser = currentUser
        if let messages = noResultsMessages {
            vc.streamViewController.noResultsMessages = messages
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: StreamViewController: SSPullToRefreshViewDelegate
extension StreamViewController: SSPullToRefreshViewDelegate {
    public func pullToRefreshViewShouldStartLoading(view: SSPullToRefreshView!) -> Bool {
        return pullToRefreshEnabled
    }

    public func pullToRefreshViewDidStartLoading(view: SSPullToRefreshView!) {
        if pullToRefreshEnabled {
            self.loadInitialPage()
        }
        else {
            pullToRefreshView?.finishLoading()
        }
    }
}

// MARK: StreamViewController : StreamCollectionViewLayoutDelegate
extension StreamViewController : StreamCollectionViewLayoutDelegate {

    public func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(UIWindow.windowWidth(), dataSource.heightForIndexPath(indexPath, numberOfColumns:1))
    }

    public func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        groupForItemAtIndexPath indexPath: NSIndexPath) -> String {
            return dataSource.groupForIndexPath(indexPath)
    }

    public func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: NSIndexPath, numberOfColumns: NSInteger) -> CGFloat {
            return dataSource.heightForIndexPath(indexPath, numberOfColumns:numberOfColumns)
    }

    public func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        isFullWidthAtIndexPath indexPath: NSIndexPath) -> Bool {
            return dataSource.isFullWidthAtIndexPath(indexPath)
    }
}

// MARK: StreamViewController: StreamImageCellDelegate
extension StreamViewController: StreamImageCellDelegate {

    public func imageTapped(imageView: FLAnimatedImageView, cell: StreamImageCell) {
        let indexPath = collectionView.indexPathForCell(cell)
        let post = indexPath.flatMap(dataSource.postForIndexPath)
        let imageAsset = indexPath.flatMap(dataSource.imageAssetForIndexPath)

        if streamKind.isGridLayout || cell.isGif {
            if let post = post {
                postTappedDelegate?.postTapped(post)
            }
        }
        else if let imageViewer = imageViewer {
            imageViewer.imageTapped(imageView, imageURL: cell.presentedImageUrl)
            if let post = post,
                    asset = imageAsset {
                Tracker.sharedTracker.viewedImage(asset, post: post)
            }
        }
    }
}

// MARK: StreamViewController : UserDelegate
extension StreamViewController : UserDelegate {

    public func userTappedText(cell: UICollectionViewCell) {
        if streamKind.tappingTextOpensDetail {
            if let indexPath = collectionView.indexPathForCell(cell) {
                collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
            }
        }
    }

    public func userTappedAvatar(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell),
           user = dataSource.userForIndexPath(indexPath)
        {
            userTappedDelegate?.userTapped(user)
        }
    }

    public func userTappedParam(param: String) {
        userTappedDelegate?.userParamTapped(param)
    }

}

// MARK: StreamViewController : WebLinkDelegate
extension StreamViewController : WebLinkDelegate {

    public func webLinkTapped(type: ElloURI, data: String) {
        switch type {
        case .Confirm, .ResetMyPassword, .FreedomOfSpeech, .FaceMaker, .Invitations, .Join, .Login, .NativeRedirect, .Onboarding, .PasswordResetError, .RandomSearch, .RequestInvitations, .SearchPeople, .SearchPosts, .ProfileFollowers, .ProfileFollowing, .ProfileLoves, .DiscoverRandom, .DiscoverRelated, .Unblock:
            break
        case .BetaPublicProfiles, .Downloads, .External, .ForgotMyPassword, .Manifesto, .RequestInvite, .RequestInvitation, .Subdomain, .WhoMadeThis, .WTF: postNotification(externalWebNotification, value: data)
        case .Discover: selectTab(.Discovery)
        case .Email: break // this is handled in ElloWebViewHelper
        case .Enter, .Exit, .Root: break // do nothing since we should already be in app
        case .Friends, .Following, .Noise, .Starred: selectTab(.Stream)
        case .Notifications: selectTab(.Notifications)
        case .Post: showPostDetail(data)
        case .Profile: showProfile(data)
        case .Search: showSearch(data)
        case .Settings: showSettings()
        }
    }

    private func showProfile(username: String) {
        let param = "~\(username)"
        if alreadyOnUserProfile(param) { return }
        let vc = ProfileViewController(userParam: param)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showPostDetail(token: String) {
        let param = "~\(token)"
        if alreadyOnPostDetail(param) { return }
        let vc = PostDetailViewController(postParam: param)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showSearch(terms: String) {
        if let searchVC = navigationController?.visibleViewController as? SearchViewController {
            searchVC.searchForPosts(terms)
        }
        else {
            let vc = SearchViewController()
            vc.currentUser = currentUser
            vc.searchForPosts(terms)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func showSettings() {
        if let settings = UIStoryboard(name: "Settings", bundle: .None).instantiateInitialViewController() as? SettingsContainerViewController {
            settings.currentUser = currentUser
            navigationController?.pushViewController(settings, animated: true)
        }
    }

    private func selectTab(tab: ElloTab) {
        elloTabBarController?.selectedTab = tab
    }
}

// MARK: StreamViewController : UICollectionViewDelegate
extension StreamViewController : UICollectionViewDelegate {

    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        dataSource.willDisplayCell(cell, forItemAtIndexPath: indexPath)
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let tappedCell = collectionView.cellForItemAtIndexPath(indexPath)

            if tappedCell is StreamToggleCell {
                dataSource.toggleCollapsedForIndexPath(indexPath)
                collectionView.reloadData()
            }
            else if tappedCell is UserListItemCell {
                if let user = dataSource.userForIndexPath(indexPath) {
                    userTappedDelegate?.userTapped(user)
                }
            }
            else if tappedCell is StreamSeeMoreCommentsCell {
                if  let comment = dataSource.commentForIndexPath(indexPath),
                    let post = comment.parentPost
                {
                    postTappedDelegate?.postTapped(post)
                }
            }
            else if let post = dataSource.postForIndexPath(indexPath) {
                postTappedDelegate?.postTapped(post)
            }
            else if let item = dataSource.visibleStreamCellItem(at: indexPath),
                let notification = item.jsonable as? Notification,
                let postId = notification.postId
            {
                postTappedDelegate?.postTapped(postId: postId)
            }
            else if let item = dataSource.visibleStreamCellItem(at: indexPath),
                let notification = item.jsonable as? Notification,
                let user = notification.subject as? User
            {
                userTappedDelegate?.userTapped(user)
            }
            else if let comment = dataSource.commentForIndexPath(indexPath),
                let post = comment.parentPost
            {
                createPostDelegate?.createComment(post, text: nil, fromController: self)
            }
    }

    public func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            if let cellItemType = dataSource.visibleStreamCellItem(at: indexPath)?.type {
                return cellItemType.selectable
            }
            return false
    }
}

// MARK: StreamViewController : UIScrollViewDelegate
extension StreamViewController : UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView : UIScrollView) {
        streamScrollDelegate?.streamViewDidScroll(scrollView)
        if !noResultsLabel.hidden {
            noResultsTopConstraint.constant = -scrollView.contentOffset.y + defaultNoResultsTopConstant
            self.view.layoutIfNeeded()
        }

        if canLoadNext {
            self.loadNextPage(scrollView)
        }
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        canLoadNext = true
        streamScrollDelegate?.streamViewWillBeginDragging?(scrollView)
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        streamScrollDelegate?.streamViewDidEndDragging?(scrollView, willDecelerate: willDecelerate)
    }

    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        canLoadNext = false
    }

    private func loadNextPage(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + (self.view.frame.height * 1.666) > scrollView.contentSize.height {
            if allOlderPagesLoaded == true { return }
            if responseConfig?.totalPagesRemaining == "0" { return }

            if let nextQueryItems = responseConfig?.nextQueryItems {
                if dataSource.visibleCellItems.count > 0 {
                    let lastCellItem: StreamCellItem = dataSource.visibleCellItems[dataSource.visibleCellItems.count - 1]
                    if lastCellItem.type == .StreamLoading { return }
                    appendStreamCellItems([StreamLoadingCell.streamCellItem()])
                }
                canLoadNext = false

                let scrollAPI = ElloAPI.InfiniteScroll(queryItems: nextQueryItems) { return self.streamKind.endpoint }
                streamService.loadStream(scrollAPI,
                    streamKind: streamKind,
                    success: {
                        (jsonables, responseConfig) in
                        self.scrollLoaded(jsonables)
                        self.responseConfig = responseConfig
                    },
                    failure: { (error, statusCode) in
                        print("failed to load stream (reason: \(error))")
                        self.scrollLoaded()
                    },
                    noContent: {
                        self.allOlderPagesLoaded = true
                        self.scrollLoaded()
                    }
                )
            }
        }
    }

    private func scrollLoaded(jsonables: [JSONAble] = []) {
        if let lastIndexPath = collectionView.lastIndexPathForSection(0) {
            if jsonables.count > 0 {
                insertUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: streamKind, currentUser: currentUser), startingIndexPath: lastIndexPath) {
                    self.removeLoadingCell()
                    self.doneLoading()
                }
            }
            else {
                removeLoadingCell()
                self.doneLoading()
            }
        }
    }

    private func removeLoadingCell() {
        if let indexPath = self.collectionView.lastIndexPathForSection(0)
            where dataSource.visibleCellItems[indexPath.row].type == .StreamLoading
        {
            dataSource.removeItemAtIndexPath(indexPath)
            collectionView.reloadData()
        }
    }
}

