//
//  StreamViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation
import UIKit


protocol WebLinkDelegate: NSObjectProtocol {
    func webLinkTapped(type: ElloURI, data: String)
}

protocol UserDelegate: NSObjectProtocol {
    func userTapped(cell: UICollectionViewCell) -> Void
}

protocol PostbarDelegate : NSObjectProtocol {
    func viewsButtonTapped(cell:StreamFooterCell)
    func commentsButtonTapped(cell:StreamFooterCell, commentsButton: CommentButton)
    func lovesButtonTapped(cell:StreamFooterCell)
    func repostButtonTapped(cell:StreamFooterCell)
}

protocol StreamImageCellDelegate : NSObjectProtocol {
    func imageTapped(imageView:UIImageView)
}

@objc protocol StreamScrollDelegate: NSObjectProtocol {
    func scrollViewDidScroll(scrollView : UIScrollView)
}



class StreamViewController: BaseElloViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var pulsingCircle : PulsingCircle?
    var scrolling = false
    var streamables:[Streamable]?
    var dataSource:StreamDataSource!
    var navBarShowing = true
    var postbarController:PostbarController?
    var relationshipController: RelationshipController?

    var streamKind:StreamKind = StreamKind.Friend {
        didSet {
            dataSource.streamKind = streamKind
            setupCollectionViewLayout()
        }
    }
    var imageViewerDelegate:StreamImageViewer?
    var updatedStreamImageCellHeightNotification:NotificationObserver?
    weak var postTappedDelegate : PostTappedDelegate?
    weak var streamScrollDelegate : StreamScrollDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }

    // If we ever create an init() method that doesn't use nib/storyboards,
    // we'll need to call this.  Called from awakeFromNib and init.
    private func initialSetup() {
        setupImageViewDelegate()
        setupDataSource()
        addNotificationObservers()
    }

    deinit {
        removeNotificationObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupPulsingCircle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let pulsingCircle = self.pulsingCircle {
            let (width, height) = (self.view.frame.size.width, self.view.frame.size.height)
            let center = CGPoint(x: width / 2, y: height / 2)
            pulsingCircle.center = center
        }
    }

    class func instantiateFromStoryboard() -> StreamViewController {
        return UIStoryboard.storyboardWithId(.Stream) as StreamViewController
    }

// MARK: Public Functions

    func doneLoading() {
        if let circle = pulsingCircle {
            circle.stopPulse() { finished in
                circle.removeFromSuperview()
            }
            pulsingCircle = nil
        }
    }

    func imageCellHeightUpdated(cell:StreamImageCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            self.updateCellHeight(indexPath, height: cell.calculatedHeight)
        }
    }

    func addStreamCellItems(items: [StreamCellItem]) {
        self.dataSource.addStreamCellItems(items)
        self.collectionView.reloadData()
    }

    func addUnsizedCellItems(items:[StreamCellItem]) {
        self.dataSource.addUnsizedCellItems(items, startingIndexPath:nil) { indexPaths in
            self.collectionView.reloadData()
        }
    }

// MARK: Private Functions

    private func setupPulsingCircle() {
        pulsingCircle = PulsingCircle.fill(self.view)
        self.view.addSubview(pulsingCircle!)
        pulsingCircle!.pulse()
    }

    private func addNotificationObservers() {
        updatedStreamImageCellHeightNotification = NotificationObserver(notification: updateStreamImageCellHeightNotification) { streamTextCell in
            self.imageCellHeightUpdated(streamTextCell)
        }
    }

    private func removeNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let imageViewer = imageViewerDelegate {
            NSNotificationCenter.defaultCenter().removeObserver(imageViewer)
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
        let layout:StreamCollectionViewLayout = collectionView.collectionViewLayout as StreamCollectionViewLayout
        layout.columnCount = streamKind.columnCount
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumColumnSpacing = 12
        layout.minimumInteritemSpacing = 0
    }

    private func setupImageViewDelegate() {
        if imageViewerDelegate == nil {
            imageViewerDelegate = StreamImageViewer(controller:self)
        }
    }

    private func setupDataSource() {
        let webView = UIWebView(frame: self.view.bounds)

        self.dataSource = StreamDataSource(testWebView: webView, streamKind: streamKind)
        self.postbarController = PostbarController(collectionView: collectionView, dataSource: self.dataSource)
        self.dataSource.postbarDelegate = postbarController

        self.relationshipController = RelationshipController(presentingController: self)
        self.dataSource.relationshipDelegate = relationshipController

        if let imageViewer = imageViewerDelegate {
            self.dataSource.imageDelegate = imageViewer
        }
        self.dataSource.webLinkDelegate = self
        self.dataSource.userDelegate = self
        collectionView.dataSource = self.dataSource
    }

    private func presentProfile(username: String) {
        println("load username: \(username)")
    }
}

// MARK: StreamViewController : WebLinkDelegate
extension StreamViewController : WebLinkDelegate {
    func webLinkTapped(type: ElloURI, data: String) {
        switch type {
        case .External: postNotification(externalWebNotification, data)
        case .Profile: presentProfile(data)
        case .Post: println("showPostDetail: \(data)")
        }
    }
}

// MARK: StreamViewController : UserDelegate
extension StreamViewController : UserDelegate {

    func userTapped(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let post = dataSource.postForIndexPath(indexPath) {
                if let user = post.author {
                    let vc = ProfileViewController(user: user)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
}

// MARK: StreamViewController : UICollectionViewDelegate
extension StreamViewController : UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if let post = dataSource.postForIndexPath(indexPath) {
                let items = self.dataSource.cellItemsForPost(post)
                postTappedDelegate?.postTapped(post, initialItems: items)
            }
    }

    func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            return self.dataSource.streamCellItems[indexPath.item].type == StreamCellType.Header
    }
}

// MARK: StreamViewController : StreamCollectionViewLayoutDelegate
extension StreamViewController : StreamCollectionViewLayoutDelegate {

    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(UIScreen.screenWidth(), dataSource.heightForIndexPath(indexPath, numberOfColumns:1))
    }

    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        groupForItemAtIndexPath indexPath: NSIndexPath) -> String {
            return dataSource.groupForIndexPath(indexPath)
    }

    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: NSIndexPath, numberOfColumns: NSInteger) -> CGFloat {
            return dataSource.heightForIndexPath(indexPath, numberOfColumns:numberOfColumns)
    }

    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        maintainAspectRatioForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            return dataSource.maintainAspectRatioForItemAtIndexPath(indexPath)
    }

    func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        isFullWidthAtIndexPath indexPath: NSIndexPath) -> Bool {
            return dataSource.isFullWidthAtIndexPath(indexPath)
    }
}

// MARK: StreamViewController : UIScrollViewDelegate
extension StreamViewController : UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView : UIScrollView) {
        self.streamScrollDelegate?.scrollViewDidScroll(scrollView)
        
        let shouldHideTabBar : ()->Bool = { return false }
        if !shouldHideTabBar() {
            return
        }

        let tabBar_ = findTabBar(self.tabBarController!.view)
        if let tabBar = tabBar_ {
            if let tabBarView = self.tabBarController?.view {
                UIView.animateWithDuration(0.5,
                    animations: {
                        var frame = tabBar.frame
                        frame.origin.y = tabBarView.frame.size.height
                        tabBar.frame = frame
                    },
                    completion: nil)
            }
        }
    }

    private func findTabBar(view: UIView) -> UITabBar? {
        if view.isKindOfClass(UITabBar.self) {
            return view as? UITabBar
        }

        var foundTabBar : UITabBar? = nil
        for subview : UIView in view.subviews as [UIView] {
            if foundTabBar == nil {
                foundTabBar = findTabBar(subview)
            }
        }
        return foundTabBar
    }
}
