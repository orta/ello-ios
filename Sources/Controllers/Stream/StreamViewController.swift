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

public protocol WebLinkDelegate: NSObjectProtocol {
    func webLinkTapped(type: ElloURI, data: String)
}

public protocol UserDelegate: NSObjectProtocol {
    func userTappedCell(cell: UICollectionViewCell)
    func userTappedParam(param: String)
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


public struct StreamNotification {
    static let AnimateCellHeightNotification = TypedNotification<StreamImageCell>(name: "AnimateCellHeightNotification")
    static let UpdateCellHeightNotification = TypedNotification<UICollectionViewCell>(name: "UpdateCellHeightNotification")
}


public class StreamViewController: BaseElloViewController {

    @IBOutlet weak public var collectionView: UICollectionView!
    var shouldReload = false
    var streamables:[Streamable]?
    public var dataSource:StreamDataSource!
    public var postbarController:PostbarController?
    var relationshipController: RelationshipController?
    var userListPresentationController: UserListPresentationController?
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
    var imageViewerDelegate: StreamImageViewer?
    var updatedStreamImageCellHeightNotification: NotificationObserver?
    var relayoutNotification: NotificationObserver?
    var commentChangedNotification: NotificationObserver?
    var postChangedNotification: NotificationObserver?
    var loveChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var settingChangedNotification: NotificationObserver?
    var currentUserChangedNotification: NotificationObserver?

    weak var createCommentDelegate : CreateCommentDelegate?
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

    var contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
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

        if let userListPresentationController = userListPresentationController {
            userListPresentationController.currentUser = currentUser
        }

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
        if shouldReload {
            shouldReload = false
            loadInitialPage()
        }
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
    }

    public func reloadCells() {
        collectionView.reloadData()
    }

    public func removeAllCellItems() {
        dataSource.removeAllCellItems()
        collectionView.reloadData()
    }

    public func imageCellHeightUpdated(cell:StreamImageCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            updateCellHeight(indexPath, height: cell.calculatedHeight)
        }
    }

    public func appendStreamCellItems(items: [StreamCellItem]) {
        dataSource.appendStreamCellItems(items)
        collectionView.reloadData()
    }

    public func appendUnsizedCellItems(items: [StreamCellItem], withWidth: CGFloat?) {
        let width = withWidth ?? self.view.frame.width
        dataSource.appendUnsizedCellItems(items, withWidth: width) { _ in
            self.collectionView.reloadData()
            self.doneLoading()
        }
    }

    public func insertUnsizedCellItems(cellItems: [StreamCellItem], startingIndexPath: NSIndexPath, completion: ElloEmptyCompletion? = nil) {
        dataSource.insertUnsizedCellItems(cellItems, withWidth: self.view.frame.width, startingIndexPath: startingIndexPath) { _ in
            self.collectionView.reloadData()
            completion?()
        }
    }

    // Inserts the new comment items under the createComment cell
    public func insertNewCommentItems(commentItems: [StreamCellItem]) {
        if count(commentItems) == 0 {
            return
        }

        let commentItem = commentItems[0]
        if  let comment = commentItem.jsonable as? Comment,
            let parentPost = comment.parentPost,
            let indexPath = dataSource.createCommentIndexPathForPost(parentPost)
        {
            // insert the items below the create comment button
            let newCommentIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
            self.insertUnsizedCellItems(commentItems, startingIndexPath: newCommentIndexPath)
        }
    }

    var loadInitialPageLoadingToken: String = ""
    public func cancelInitialPage() {
        let localToken = NSUUID().UUIDString
        loadInitialPageLoadingToken = localToken
        self.doneLoading()
    }

    public var initialLoadClosure: ElloEmptyCompletion?

    public func loadInitialPage() {
        if let initialLoadClosure = initialLoadClosure {
            initialLoadClosure()
        }
        else {
            let localToken = NSUUID().UUIDString
            loadInitialPageLoadingToken = localToken

            streamService.loadStream(
                streamKind.endpoint,
                streamKind: streamKind,
                success: { (jsonables, responseConfig) in
                    if self.loadInitialPageLoadingToken != localToken { return }
                    self.clearForInitialLoad()
                    self.appendUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: self.streamKind), withWidth: nil)
                    self.responseConfig = responseConfig
                    self.initialDataLoaded = true
                    self.doneLoading()
                }, failure: { (error, statusCode) in
                    println("failed to load \(self.streamKind.name) stream (reason: \(error))")
                    self.initialLoadFailure()
                    self.doneLoading()
                }, noContent: {
                    println("nothing new")
                    self.initialDataLoaded = true
                    self.doneLoading()
                }
            )
        }
    }

    public func clearForInitialLoad() {
        allOlderPagesLoaded = false
        dataSource.removeAllCellItems()
        collectionView.reloadData()
    }

// MARK: Private Functions

    private func initialLoadFailure() {
        let message = NSLocalizedString("Something went wrong. Thank you for your patience with Ello Beta!", comment: "Initial stream load failure")
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    private func addNotificationObservers() {
        updatedStreamImageCellHeightNotification = NotificationObserver(notification: StreamNotification.AnimateCellHeightNotification) { streamImageCell in
            self.imageCellHeightUpdated(streamImageCell)
        }
        relayoutNotification = NotificationObserver(notification: StreamNotification.UpdateCellHeightNotification) { streamTextCell in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }

        commentChangedNotification = NotificationObserver(notification: CommentChangedNotification) { (comment, change) in
            if !self.initialDataLoaded {
                return
            }
            switch change {
            case .Create, .Delete, .Update:
                self.dataSource.modifyItems(comment, change: change, collectionView: self.collectionView)
            case .Read: break
            }
        }

        postChangedNotification = NotificationObserver(notification: PostChangedNotification) { (post, change) in
            if !self.initialDataLoaded {
                return
            }
            switch change {
            case .Create:
                self.dataSource.modifyItems(post, change: change, collectionView: self.collectionView)
            case .Delete:
                switch self.streamKind {
                case .PostDetail: break
                default:
                    self.dataSource.modifyItems(post, change: change, collectionView: self.collectionView)
                }
                // reload page
            case .Update:
                self.dataSource.modifyItems(post, change: change, collectionView: self.collectionView)
            case .Read: break
            }
        }

        loveChangedNotification  = NotificationObserver(notification: LoveChangedNotification) { (love, change) in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyItems(love, change: change, collectionView: self.collectionView)
        }

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { user in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyUserRelationshipItems(user, collectionView: self.collectionView)
        }

        settingChangedNotification = NotificationObserver(notification: SettingChangedNotification) { user in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyUserSettingsItems(user, collectionView: self.collectionView)
        }

        currentUserChangedNotification = NotificationObserver(notification: CurrentUserChangedNotification) { user in
            if !self.initialDataLoaded {
                return
            }
            self.dataSource.modifyItems(user, change: .Update, collectionView: self.collectionView)
        }
    }

    private func removeNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let imageViewerDelegate = imageViewerDelegate {
            NSNotificationCenter.defaultCenter().removeObserver(imageViewerDelegate)
        }

        updatedStreamImageCellHeightNotification?.removeObserver()
        updatedStreamImageCellHeightNotification = nil

        relayoutNotification?.removeObserver()
        relayoutNotification = nil

        commentChangedNotification?.removeObserver()
        commentChangedNotification = nil

        postChangedNotification?.removeObserver()
        postChangedNotification = nil

        relationshipChangedNotification?.removeObserver()
        relationshipChangedNotification = nil

        loveChangedNotification?.removeObserver()
        loveChangedNotification = nil
    }

    private func updateCellHeight(indexPath:NSIndexPath, height:CGFloat) {
        collectionView.performBatchUpdates({
            self.dataSource.updateHeightForIndexPath(indexPath, height: height)
        }, completion: { (finished) in

        })
        collectionView.reloadItemsAtIndexPaths([indexPath])
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
        let layout:StreamCollectionViewLayout = collectionView.collectionViewLayout as! StreamCollectionViewLayout
        layout.columnCount = streamKind.columnCount
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumColumnSpacing = 12
        layout.minimumInteritemSpacing = 0
    }

    private func setupImageViewDelegate() {
        if imageViewerDelegate == nil {
            imageViewerDelegate = StreamImageViewer(presentingController: self, collectionView: collectionView, dataSource: dataSource)
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
            if let post = item.jsonable as? Post {
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

        userListPresentationController = UserListPresentationController(presentingController: self)
        userListPresentationController!.currentUser = currentUser
        dataSource.userListDelegate = userListPresentationController

        dataSource.imageDelegate = self
        dataSource.webLinkDelegate = self
        dataSource.userDelegate = self
        collectionView.dataSource = dataSource
    }

}

// MARK: StreamViewController : WebLinkDelegate
extension StreamViewController : WebLinkDelegate {
    public func webLinkTapped(type: ElloURI, data: String) {
        switch type {
        case .External: postNotification(externalWebNotification, data)
        case .Profile: presentProfile(data)
        case .Post: showPostDetail(data)
        }
    }

    private func presentProfile(username: String) {
        let param = "~\(username)"
        if alreadyOnUserProfile(param) { return }
        let vc = ProfileViewController(userParam: param)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func showPostDetail(token: String) {
        let param = "~\(token)"
        if alreadyOnPostDetail(param) { return }
        let vc = PostDetailViewController(postParam: param)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: StreamViewController : UserDelegate
extension StreamViewController : UserDelegate {

    public func userTappedCell(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let user = dataSource.userForIndexPath(indexPath) {
                userTappedDelegate?.userTapped(user)
            }
        }
    }

    public func userTappedParam(param: String) {
        userTappedDelegate?.userParamTapped(param)
    }

}

// MARK: StreamViewController : UICollectionViewDelegate
extension StreamViewController : UICollectionViewDelegate {

    public func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
                createCommentDelegate?.createComment(post, text: "", fromController: self)
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

// MARK: StreamViewController : StreamCollectionViewLayoutDelegate
extension StreamViewController : StreamCollectionViewLayoutDelegate {

    public func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(UIScreen.screenWidth(), dataSource.heightForIndexPath(indexPath, numberOfColumns:1))
    }

    public func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        groupForItemAtIndexPath indexPath: NSIndexPath) -> String {
            return dataSource.groupForIndexPath(indexPath)
    }

    public func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: NSIndexPath, numberOfColumns: NSInteger) -> CGFloat {
            return dataSource.heightForIndexPath(indexPath, numberOfColumns:numberOfColumns)
    }

    public func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        maintainAspectRatioForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            return dataSource.maintainAspectRatioForItemAtIndexPath(indexPath)
    }

    public func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        isFullWidthAtIndexPath indexPath: NSIndexPath) -> Bool {
            return dataSource.isFullWidthAtIndexPath(indexPath)
    }
}

// MARK: StreamViewController : UIScrollViewDelegate
extension StreamViewController : UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView : UIScrollView) {
        streamScrollDelegate?.streamViewDidScroll(scrollView)
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        streamScrollDelegate?.streamViewWillBeginDragging?(scrollView)
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        streamScrollDelegate?.streamViewDidEndDragging?(scrollView, willDecelerate: willDecelerate)
        self.loadNextPage(scrollView)
    }

    private func loadNextPage(scrollView: UIScrollView) {
        let scrollPastThreshold = CGFloat(300)
        if scrollView.contentOffset.y + self.view.frame.height + scrollPastThreshold > scrollView.contentSize.height {
            if allOlderPagesLoaded == true { return }
            if responseConfig?.totalPagesRemaining == "0" { return }

            if let nextQueryItems = responseConfig?.nextQueryItems {
                if dataSource.visibleCellItems.count > 0 {
                    let lastCellItem: StreamCellItem = dataSource.visibleCellItems[dataSource.visibleCellItems.count - 1]
                    if lastCellItem.type == .StreamLoading { return }
                    appendStreamCellItems([StreamLoadingCell.streamCellItem()])
                }

                let scrollAPI = ElloAPI.InfiniteScroll(queryItems: nextQueryItems) { return self.streamKind.endpoint }
                streamService.loadStream(scrollAPI,
                    streamKind: streamKind,
                    success: {
                        (jsonables, responseConfig) in
                        self.scrollLoaded(jsonables: jsonables)
                        self.responseConfig = responseConfig
                        self.doneLoading()
                    },
                    failure: { (error, statusCode) in
                        println("failed to load stream (reason: \(error))")
                        self.scrollLoaded()
                        self.doneLoading()
                    },
                    noContent: {
                        self.allOlderPagesLoaded = true
                        self.scrollLoaded()
                        self.doneLoading()
                    }
                )
            }
        }
    }

    private func scrollLoaded(jsonables: [JSONAble] = []) {
        if let lastIndexPath = collectionView.lastIndexPathForSection(0) {
            if jsonables.count > 0 {
                insertUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: streamKind), startingIndexPath: lastIndexPath) {
                    self.removeLoadingCell()
                }
            }
            else {
                removeLoadingCell()
            }
        }
    }

    private func removeLoadingCell() {
        if let indexPath = self.collectionView.lastIndexPathForSection(0)
            where dataSource.visibleCellItems[indexPath.row].type == .StreamLoading
        {
            dataSource.removeItemAtIndexPath(indexPath)
            collectionView.deleteItemsAtIndexPaths([indexPath])
        }
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
        else if let imageViewerDelegate = imageViewerDelegate {
            imageViewerDelegate.imageTapped(imageView, cell: cell)
            if let post = post,
                    asset = imageAsset {
                Tracker.sharedTracker.viewedImage(asset, post: post)
            }
        }
    }
}

