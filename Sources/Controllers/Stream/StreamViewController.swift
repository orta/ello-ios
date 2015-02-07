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
    func webLinkTapped(type: RequestType, data: String)
}

class StreamViewController: BaseElloViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var pulsingCircle : PulsingCircle?
    var scrolling = false
    var streamables:[Streamable]?
    var dataSource:StreamDataSource!
    var navBarShowing = true

    var streamKind:StreamKind = StreamKind.Friend {
        didSet { setupCollectionViewLayout() }
    }
    var imageViewerDelegate:StreamImageViewer?
    var updatedStreamImageCellHeightNotification:NotificationObserver?
    weak var postTappedDelegate : PostTappedDelegate?

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

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> StreamViewController {
        return storyboard.controllerWithID(.Stream) as StreamViewController
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

    func addStreamables(streamables:[Streamable]) {
        self.dataSource.addStreamables(streamables, startingIndexPath:nil) { (cellCount) -> () in
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
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
        collectionView.directionalLockEnabled = true
        registerCells()
        setupCollectionViewLayout()
    }

    private func registerCells() {
        let streamHeaderCellNib = UINib(nibName: StreamCellType.Header.name, bundle: nil)
        collectionView.registerNib(streamHeaderCellNib, forCellWithReuseIdentifier: StreamCellType.Header.name)

        let streamImageCellNib = UINib(nibName: StreamCellType.Image.name, bundle: nil)
        collectionView.registerNib(streamImageCellNib, forCellWithReuseIdentifier: StreamCellType.Image.name)

        let streamTextCellNib = UINib(nibName: StreamCellType.Text.name, bundle: nil)
        collectionView.registerNib(streamTextCellNib, forCellWithReuseIdentifier: StreamCellType.Text.name)

        let streamFooterCellNib = UINib(nibName: StreamCellType.Footer.name, bundle: nil)
        collectionView.registerNib(streamFooterCellNib, forCellWithReuseIdentifier: StreamCellType.Footer.name)

        let streamCommentHeaderCellNib = UINib(nibName: StreamCellType.CommentHeader.name, bundle: nil)
        collectionView.registerNib(streamCommentHeaderCellNib, forCellWithReuseIdentifier: StreamCellType.CommentHeader.name)

        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: StreamCellType.Unknown.name)
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
        self.dataSource.postbarDelegate = PostbarController(collectionView: collectionView, dataSource: self.dataSource)
        if let imageViewer = imageViewerDelegate {
            self.dataSource.imageDelegate = imageViewer
        }
        self.dataSource.webLinkDelegate = self
        collectionView.dataSource = self.dataSource
    }

    private func presentProfile(username: String) {
        let controller = ProfileViewController.instantiateFromStoryboard()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: StreamViewController : WebLinkDelegate
extension StreamViewController : WebLinkDelegate {
    func webLinkTapped(type: RequestType, data: String) {
        switch type {
        case .External: postNotification(externalWebNotification, data)
        case .Profile: presentProfile(data)
        case .Post: println("showPostDetail: \(data)")
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
            return !streamKind.isDetail && self.dataSource.streamCellItems[indexPath.item].type == StreamCellItem.CellType.Header
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
}

// MARK: StreamViewController : UIScrollViewDelegate
extension StreamViewController : UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView : UIScrollView) {
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