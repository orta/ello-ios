//
//  FriendsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation
import UIKit

class FriendsViewController: BaseElloViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    var scrolling = false
    var activities:[Activity]?
    var dataSource:FriendsDataSource!
    var tabBarFrame = CGRectZero
    var navBarShowing = true


    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addNotificationObservers()
//        self.edgesForExtendedLayout = .Bottom
//        self.extendedLayoutIncludesOpaqueBars = true
//        self.automaticallyAdjustsScrollViewInsets = false

        navigationController?.hidesBarsOnSwipe = true
//        self.addObserver(self, forKeyPath: "view.frame", options: nil, context: nil)
//        navigationController?.setToolbarHidden(true, animated: true)

        if let tabBar = self.tabBarController?.tabBar {
            tabBarFrame = tabBar.frame
        }

        self.dataSource = FriendsDataSource(controller: self)

        ElloHUD.showLoadingHud()
        let streamService = StreamService()
        streamService.loadFriendStream({ (activities) in
            ElloHUD.hideLoadingHud()
            self.activities = activities
            self.dataSource.activities = activities
            self.dataSource.viewController = self
            self.collectionView.dataSource = self.dataSource
            self.collectionView.reloadData()
        }, failure: { (error, statusCode) in
            ElloHUD.hideLoadingHud()
            println("failed to load friends stream")
        })
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        println("keyPath: \(keyPath), object: \(object), change: \(change)")
//        println("view.frame = \(view.frame)")
        if keyPath == "view.frame" {
            let shouldHideTabBar = self.view.frame.origin.y == 0
            if navBarShowing && shouldHideTabBar {
                println("hiding")
                navBarShowing = false
                self.tabBarController?.setTabBarHidden(true, animated: true)
            } else if !navBarShowing && !shouldHideTabBar {
                println("showing")
                navBarShowing = true
                self.tabBarController?.setTabBarHidden(false, animated: true)
            }
        }
    }

    func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellHeightUpdated:", name: "UpdateHeightNotification", object: nil)
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

    func setupCollectionView() {
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
