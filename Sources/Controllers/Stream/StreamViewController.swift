//
//  StreamViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation
import UIKit

class StreamViewController: BaseElloViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var scrolling = false
    var streamables:[Streamable]?
    var dataSource:StreamDataSource!
    var navBarShowing = true

    var streamKind:StreamKind = StreamKind.Friend
    var detailCellItems:[StreamCellItem]?
    var imageViewerDelegate:StreamImageViewer?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewerDelegate = StreamImageViewer(controller:self)
        setupCollectionView()
        addNotificationObservers()
        setupDataSource()
        prepareForStreamType()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> StreamViewController {
        return storyboard.controllerWithID(.Stream) as StreamViewController
    }

// MARK: Public Functions

    func cellHeightUpdated(notification:NSNotification) {
        if let cell = notification.object? as? StreamImageCell {
            if let indexPath = collectionView.indexPathForCell(cell) {
                self.updateCellHeight(indexPath, height: cell.calculatedHeight)
            }
        }
        if let cell = notification.object? as? StreamTextCell {
            if let indexPath = collectionView.indexPathForCell(cell) {
                self.updateCellHeight(indexPath, height: cell.calculatedHeight)
            }
        }
    }

// MARK: Private Functions

    private func setupForDetail(post:Post) {
        if let username = post.author?.username {
            self.title = "@" + username
        }

        if let cellItems = self.detailCellItems {
            self.dataSource.streamCellItems = cellItems
            self.collectionView.dataSource = self.dataSource
            self.collectionView.reloadData()
        }

        let streamService = StreamService()
        streamService.loadMoreCommentsForPost(post.postId,
            success: { (streamables) -> () in
                self.dataSource.addStreamables(streamables, completion: { (indexPaths) -> () in
                    self.collectionView.dataSource = self.dataSource
                    self.collectionView.insertItemsAtIndexPaths(indexPaths)
                    }, startingIndexPath:nil)
            }) { (error, statusCode) -> () in
                println("failed to load comments")
        }
    }

    private func setupForStream(streamKind:StreamKind) {
        let streamService = StreamService()
        //        ElloHUD.showLoadingHud()
        streamService.loadStream(streamKind.endpoint,
            success:{ (streamables) in
            //            ElloHUD.hideLoadingHud()
            self.streamables = streamables

            self.dataSource.addStreamables(streamables, completion: { (cellCount) -> () in
                let layout:StreamCollectionViewLayout = self.collectionView.collectionViewLayout as StreamCollectionViewLayout
                layout.columnCount = streamKind.columnCount
                self.collectionView.dataSource = self.dataSource
                self.collectionView.reloadData()
                }, startingIndexPath:nil)
            }, failure: { (error, statusCode) in
                //                ElloHUD.hideLoadingHud()
                println("failed to load noise stream")
        })
    }

    private func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellHeightUpdated:", name: "UpdateHeightNotification", object: nil)
        if let imageViewer = imageViewerDelegate {
            NSNotificationCenter.defaultCenter().addObserver(imageViewer, selector: "imageTapped:", name: "ImageTappedNotification", object: nil)
        }
    }

    private func updateCellHeight(indexPath:NSIndexPath, height:CGFloat) {
        collectionView.performBatchUpdates({
            self.dataSource.updateHeightForIndexPath(indexPath, height: height)
        }, completion: { (finished) -> Void in

        })
    }

    private func setupCollectionView() {
        let layout:StreamCollectionViewLayout = collectionView.collectionViewLayout as StreamCollectionViewLayout
        layout.columnCount = 1
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumColumnSpacing = 12
        layout.minimumInteritemSpacing = 0

        collectionView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
    }

    private func setupDataSource() {
        let webView = UIWebView(frame: self.view.bounds)

        self.dataSource = StreamDataSource(testWebView: webView, streamKind: streamKind)
        self.dataSource.postbarDelegate = PostbarController(collectionView: collectionView, dataSource: self.dataSource)
    }

    private func prepareForStreamType() {
        switch streamKind {
        case .PostDetail(let post):
            setupForDetail(post)
        default: setupForStream(streamKind)
        }
    }
}

extension StreamViewController : UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if let post = dataSource.postForIndexPath(indexPath) {
                let vc = StreamViewController.instantiateFromStoryboard()
                vc.streamKind = .PostDetail(post:post)
                vc.detailCellItems = self.dataSource.cellItemsForPost(post)

                NSNotificationCenter.defaultCenter().postNotificationName(StreamContainerViewController.Notifications.StreamDetailTapped.rawValue, object: vc)
            }
    }

    func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            return !streamKind.isDetail && self.dataSource.streamCellItems[indexPath.item].type == StreamCellItem.CellType.Header
    }
}

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