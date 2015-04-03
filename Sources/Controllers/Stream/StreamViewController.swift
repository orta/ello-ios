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

typealias InfiniteScrollClosure = (jsonables: [JSONAble]) -> () // TODO: this line can be removed when author is added to posts

public protocol WebLinkDelegate: NSObjectProtocol {
    func webLinkTapped(type: ElloURI, data: String)
}

public protocol UserDelegate: NSObjectProtocol {
    func userTappedCell(cell: UICollectionViewCell)
}

public protocol PostbarDelegate : NSObjectProtocol {
    func viewsButtonTapped(cell:UICollectionViewCell)
    func commentsButtonTapped(cell:StreamFooterCell, commentsButton: CommentButton)
    func lovesButtonTapped(cell:UICollectionViewCell)
    func repostButtonTapped(cell:UICollectionViewCell)
    func shareButtonTapped(cell:UICollectionViewCell)
    func flagPostButtonTapped(cell:UICollectionViewCell)
    func flagCommentButtonTapped(cell:UICollectionViewCell)
    func replyToPostButtonTapped(cell:UICollectionViewCell)
    func replyToCommentButtonTapped(cell:UICollectionViewCell)
}

public protocol StreamImageCellDelegate : NSObjectProtocol {
    func imageTapped(imageView: FLAnimatedImageView, cell: UICollectionViewCell)
}

@objc
public protocol StreamScrollDelegate: NSObjectProtocol {
    func streamViewDidScroll(scrollView : UIScrollView)
    optional func streamViewWillBeginDragging(scrollView: UIScrollView)
    optional func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
}


let RelayoutStreamViewControllerNotification = TypedNotification<UICollectionViewCell>(name: "RelayoutStreamViewControllerNotification")


public class StreamViewController: BaseElloViewController {

    @IBOutlet weak public var collectionView: UICollectionView!
    var pulsingCircle : PulsingCircle?
    var streamables:[Streamable]?
    var refreshableIndex: Int?
    public var dataSource:StreamDataSource!
    public var postbarController:PostbarController?
    var relationshipController: RelationshipController?
    var userListController: UserListController?
    public var responseConfig: ResponseConfig?
    public let streamService = StreamService()
    public var pullToRefreshView: SSPullToRefreshView?
    var allOlderPagesLoaded = false
    var restoreTabBar: Bool? = nil
    var parentTabBarController: ElloTabBarController? {
        if let parentViewController = self.parentViewController {
            if let elloController = parentViewController as? BaseElloViewController {
                return elloController.elloTabBarController
            }
        }
        return nil
    }
    var infiniteScrollClosure: InfiniteScrollClosure? // TODO: this line can be removed when author is added to posts

    public var streamKind:StreamKind = StreamKind.Friend {
        didSet {
            dataSource.streamKind = streamKind
            setupCollectionViewLayout()
        }
    }
    var imageViewerDelegate:StreamImageViewer?
    var updatedStreamImageCellHeightNotification:NotificationObserver?
    var relayoutNotification:NotificationObserver?
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
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let restoreTabBar = self.restoreTabBar {
            self.parentTabBarController?.setTabBarHidden(restoreTabBar, animated: false)
        }
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let restoreTabBar = self.restoreTabBar {
            self.parentTabBarController?.setTabBarHidden(restoreTabBar, animated: false)
            self.restoreTabBar = nil
        }
    }

    override public func didSetCurrentUser() {
        dataSource.currentUser = currentUser
        if let userListController = userListController {
            userListController.currentUser = currentUser
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
        pullToRefreshView = SSPullToRefreshView(scrollView:collectionView, delegate: self)
        pullToRefreshView?.contentView = ElloPullToRefreshView(frame:CGRectZero)
        setupCollectionView()
    }

    public class func instantiateFromStoryboard() -> StreamViewController {
        return UIStoryboard.storyboardWithId(.Stream) as! StreamViewController
    }

// MARK: Public Functions

    public func doneLoading() {
        ElloHUD.hideLoadingHudInView(view)
        pullToRefreshView?.finishLoading()
    }

    public func removeRefreshables() {
        if let refreshableIndex = refreshableIndex {
            dataSource.removeCellItemsBelow(refreshableIndex)
        }
        else {
            dataSource.removeAllCellItems()
        }
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

    public func appendUnsizedCellItems(items: [StreamCellItem]) {
        dataSource.appendUnsizedCellItems(items, withWidth: self.view.frame.width) { _ in
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

    public func insertNewCommentItems(commentItems: [StreamCellItem]) {
        if count(commentItems) == 0 {
            return
        }

        let commentItem = commentItems[0]
        if let comment = commentItem.jsonable as? Comment,
           let parentPost = comment.parentPost,
           let indexPath = dataSource.createCommentIndexPathForPost(parentPost) {
            let newCommentIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
            self.insertUnsizedCellItems(commentItems, startingIndexPath: newCommentIndexPath)
        }
    }

    public func loadInitialPage() {
        ElloHUD.showLoadingHudInView(view)
        streamService.loadStream(streamKind.endpoint,
            success: { (jsonables, responseConfig) in
                self.appendUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: self.streamKind))
                self.responseConfig = responseConfig
            }, failure: { (error, statusCode) in
                println("failed to load \(self.streamKind.name) stream (reason: \(error))")
                self.doneLoading()
            }
        )
    }

// MARK: Private Functions

    private func addNotificationObservers() {
        updatedStreamImageCellHeightNotification = NotificationObserver(notification: updateStreamImageCellHeightNotification) { streamTextCell in
            self.imageCellHeightUpdated(streamTextCell)
        }
        relayoutNotification = NotificationObserver(notification: RelayoutStreamViewControllerNotification) { streamTextCell in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    private func removeNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let imageViewerDelegate = imageViewerDelegate {
            NSNotificationCenter.defaultCenter().removeObserver(imageViewerDelegate)
        }
        if let updatedStreamImageCellHeightNotification = updatedStreamImageCellHeightNotification {
            updatedStreamImageCellHeightNotification.removeObserver()
            self.updatedStreamImageCellHeightNotification = nil
        }
        if let relayoutNotification = relayoutNotification {
            relayoutNotification.removeObserver()
            self.relayoutNotification = nil
        }
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
        let textSizeCalculator = StreamTextCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let notificationSizeCalculator = StreamNotificationCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let profileHeaderSizeCalculator = ProfileHeaderCellSizeCalculator(webView: UIWebView(frame: webView.frame))

        dataSource = StreamDataSource(streamKind: streamKind,
            textSizeCalculator: textSizeCalculator,
            notificationSizeCalculator: notificationSizeCalculator,
            profileHeaderSizeCalculator: profileHeaderSizeCalculator)

        dataSource.streamCollapsedFilter = { item in
            if !item.type.collapsable {
                return true
            }
            if let post = item.jsonable as? Post {
                return !post.collapsed
            }
            return true
        }

        let postbarController = PostbarController(collectionView: collectionView, dataSource: dataSource, presentingController: self)
        postbarController.currentUser = currentUser
        dataSource.postbarDelegate = postbarController
        self.postbarController = postbarController

        relationshipController = RelationshipController(presentingController: self)
        dataSource.relationshipDelegate = relationshipController

        userListController = UserListController(presentingController: self)
        userListController!.currentUser = currentUser
        dataSource.userListDelegate = userListController

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
        vc.didPresentStreamable()
    }

    private func showPostDetail(token: String) {
        let param = "~\(token)"
        if alreadyOnPostDetail(param) { return }
        let vc = PostDetailViewController(postParam: param)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
        vc.didPresentStreamable()
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

}

// MARK: StreamViewController : UICollectionViewDelegate
extension StreamViewController : UICollectionViewDelegate {

    public func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? StreamToggleCell {
                dataSource.toggleCollapsedForIndexPath(indexPath)
                collectionView.reloadData()
            }
            else if let post = dataSource.postForIndexPath(indexPath) {
                let items = dataSource.cellItemsForPost(post)
                postTappedDelegate?.postTapped(post, initialItems: items)
            }
            else if let comment = dataSource.commentForIndexPath(indexPath) {
                let post = comment.parentPost!
                createCommentDelegate?.createComment(post, fromController: self)
            }
    }

    public func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            if let cellItemType = dataSource.visibleStreamCellItem(at: indexPath)?.type {
                switch cellItemType {
                case .Header, .CreateComment, .Toggle: return true
                default: return false
                }
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
        self.streamScrollDelegate?.streamViewDidScroll(scrollView)
        self.loadNextPage(scrollView)
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if let delegate = self.streamScrollDelegate {
            delegate.streamViewWillBeginDragging?(scrollView)
        }
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        if let delegate = self.streamScrollDelegate {
            delegate.streamViewDidEndDragging?(scrollView, willDecelerate: willDecelerate)
        }
    }

    private func loadNextPage(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + self.view.frame.height + 300 > scrollView.contentSize.height {
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
                    success: {
                        (jsonables, responseConfig) in
                        self.infiniteScrollClosure?(jsonables: jsonables) // TODO: this line can be removed when author is added to posts
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
        if jsonables.count > 0 {
            insertUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: streamKind), startingIndexPath: collectionView.lastIndexPathForSection(0)) {
                self.removeLoadingCell(self.collectionView.lastIndexPathForSection(0))
            }
        }
        else {
            removeLoadingCell(collectionView.lastIndexPathForSection(0))
        }
    }

    private func removeLoadingCell(indexPath: NSIndexPath) {
        if dataSource.visibleCellItems[indexPath.row].type == .StreamLoading {
            dataSource.removeItemAtIndexPath(indexPath)
            collectionView.deleteItemsAtIndexPaths([indexPath])
        }
    }
}

extension StreamViewController: SSPullToRefreshViewDelegate {
    public func pullToRefreshViewShouldStartLoading(view: SSPullToRefreshView!) -> Bool {
        return true
    }

    public func pullToRefreshViewDidStartLoading(view: SSPullToRefreshView!) {
        self.streamService.loadStream(streamKind.endpoint,
            success: { (jsonables, responseConfig) in
                let index = self.refreshableIndex ?? 0
                self.allOlderPagesLoaded = false
                self.dataSource.removeCellItemsBelow(index)
                self.collectionView.reloadData()
                self.appendUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: self.streamKind))
                self.responseConfig = responseConfig
                view.finishLoading()
            }, failure: { (error, statusCode) in
                println("failed to load \(self.streamKind.name) stream (reason: \(error))")
                view.finishLoading()
            }
        )
    }
}

extension StreamViewController: StreamImageCellDelegate {

    public func imageTapped(imageView: FLAnimatedImageView, cell: UICollectionViewCell) {
        if let imageViewerDelegate = imageViewerDelegate {
            restoreTabBar = self.parentTabBarController?.tabBarHidden
            imageViewerDelegate.imageTapped(imageView, cell: cell)
        }
    }

}
