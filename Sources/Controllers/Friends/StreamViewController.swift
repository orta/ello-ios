//
//  StreamViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation
import UIKit

class StreamViewController: BaseElloViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, JTSImageViewControllerOptionsDelegate, JTSImageViewControllerDismissalDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var scrolling = false
    var streamables:[Streamable]?
    var dataSource:StreamDataSource!
    var navBarShowing = true
    
    var isDetail = false
    var detailPost:Post?
    var detailCellItems:[StreamCellItem]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addNotificationObservers()

        let webView = UIWebView(frame: self.view.bounds)

        self.dataSource = StreamDataSource(testWebView: webView)
        self.dataSource.postbarDelegate = PostbarController(collectionView: collectionView, dataSource: self.dataSource)

        if isDetail {
            setupForDetail()
        }
        else {
            setupForStream()
        }
    }
    
    private func setupForDetail() {
        if let username = self.detailPost?.author?.username {
            self.title = "@" + username
        }
        
        if let cellItems = self.detailCellItems {
            self.dataSource.streamCellItems = cellItems
            self.collectionView.dataSource = self.dataSource
            self.collectionView.reloadData()
        }
        
        if let post = detailPost {
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
    }
    
    private func setupForStream() {
        let streamService = StreamService()
        ElloHUD.showLoadingHud()
        streamService.loadFriendStream({ (streamables) in
            ElloHUD.hideLoadingHud()
            self.streamables = streamables

            self.dataSource.addStreamables(streamables, completion: { (cellCount) -> () in
                self.collectionView.dataSource = self.dataSource
                self.collectionView.reloadData()
            }, startingIndexPath:nil)
        }, failure: { (error, statusCode) in
                ElloHUD.hideLoadingHud()
                println("failed to load friends stream")
        })
    }
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if self.isDetail {
                return
            }
            if let post = dataSource.postForIndexPath(indexPath) {
                let vc = StreamViewController.instantiateFromStoryboard()
                vc.isDetail = true
                vc.detailPost = post
                vc.detailCellItems = self.dataSource.cellItemsForPost(post)
                
                NSNotificationCenter.defaultCenter().postNotificationName(StreamContainerViewController.Notifications.StreamDetailTapped.rawValue, object: vc)
    //            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
    }

//    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        if keyPath == "view.frame" {
//            let shouldHideTabBar = self.view.frame.origin.y == 0
//            if navBarShowing && shouldHideTabBar {
//                println("hiding")
//                navBarShowing = false
//                self.tabBarController?.setTabBarHidden(true, animated: true)
//            } else if !navBarShowing && !shouldHideTabBar {
//                println("showing")
//                navBarShowing = true
//                self.tabBarController?.setTabBarHidden(false, animated: true)
//            }
//        }
//    }

    private func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellHeightUpdated:", name: "UpdateHeightNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageTapped:", name: "ImageTappedNotification", object: nil)
    }
    
    func imageTapped(notification:NSNotification) {
        if let imageView = notification.object as? UIImageView {
            let imageInfo = JTSImageInfo()
            imageInfo.image = imageView.image
            imageInfo.referenceRect = imageView.frame
            imageInfo.referenceView = imageView.superview
            let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOption.None)
            let transition:JTSImageViewControllerTransition = ._FromOriginalPosition
            imageViewer.showFromViewController(self, transition: transition)
            imageViewer.optionsDelegate = self
            imageViewer.dismissalDelegate = self
        }
    }
    
    func alphaForBackgroundDimmingOverlayInImageViewer(imageViewer: JTSImageViewController!) -> CGFloat {
        return 1.0
    }
    
    func imageViewerDidDismiss(imageViewer: JTSImageViewController!) {
    }

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

    private func updateCellHeight(indexPath:NSIndexPath, height:CGFloat) {
        collectionView.performBatchUpdates({
            self.dataSource.updateHeightForIndexPath(indexPath, height: height)
        }, completion: { (finished) -> Void in

        })

//        collectionView.reloadItemsAtIndexPaths([indexPath])
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> StreamViewController {
        return storyboard.controllerWithID(.Stream) as StreamViewController
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(UIScreen.screenWidth(), dataSource.heightForIndexPath(indexPath))
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrolling = false
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrolling = false
        }
    }
}
