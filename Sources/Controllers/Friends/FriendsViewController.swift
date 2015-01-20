//
//  FriendsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation
import UIKit

class FriendsViewController: BaseElloViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, JTSImageViewControllerOptionsDelegate, JTSImageViewControllerDismissalDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var scrolling = false
    var activities:[Activity]?
    var dataSource:FriendsDataSource!
    var navBarShowing = true
    var isDetail = false
    var detailPost:Post?
    var detailCellItems:[StreamCellItem]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addNotificationObservers()

        let webView = UIWebView(frame: self.view.bounds)
        self.dataSource = FriendsDataSource(testWebView: webView)
        
        
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
        
//        let streamService = StreamService()
        
    }
    
    private func setupForStream() {
        let streamService = StreamService()
        ElloHUD.showLoadingHud()
        streamService.loadFriendStream({ (activities) in
            ElloHUD.hideLoadingHud()
            self.activities = activities
            self.dataSource.addActivities(activities, completion: {
                self.collectionView.dataSource = self.dataSource
                self.collectionView.reloadData()
            })
            }, failure: { (error, statusCode) in
                ElloHUD.hideLoadingHud()
                println("failed to load friends stream")
        })
    }
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let post = dataSource.postForIndexPath(indexPath) {
            let vc = FriendsViewController.instantiateFromStoryboard()
            vc.isDetail = true
            vc.detailPost = post
            vc.detailCellItems = self.dataSource.cellItemsForPost(post)
            
            NSNotificationCenter.defaultCenter().postNotificationName(StreamViewController.Notifications.StreamDetailTapped.rawValue, object: vc)
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

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> FriendsViewController {
        return storyboard.controllerWithID(.Friends) as FriendsViewController
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

//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let velocity = scrollView.panGestureRecognizer.velocityInView(scrollView.superview)
//        let directionUp = velocity.y < 0
//        if !self.scrolling {
//            if let tabBar = self.tabBarController?.tabBar {
//                if directionUp {
//                    self.tabBarController?.setTabBarHidden(true, animated: true)
////                    UIView.animateWithDuration(0.15, animations: {
////                        tabBar.frame = CGRectMake(tabBar.frame.origin.x,  self.tabBarFrame.origin.y + tabBar.frame.size.height, tabBar.frame.size.width, tabBar.frame.size.height)
////                        }, completion: { (finished) -> Void in
////                    })
//                }
//                else {
//                    self.tabBarController?.setTabBarHidden(false, animated: true)
////                    UIView.animateWithDuration(0.15, animations: {
////                        tabBar.frame = self.tabBarFrame
////                        }, completion: { (finished) -> Void in
////                    })
//                }
//            }
//            self.scrolling = true
//        }
//    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrolling = false
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrolling = false
        }
    }
    
    
    
}
