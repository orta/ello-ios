//
//  FriendsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class FriendsViewController: BaseElloViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    var activities:[Activity]?
    let dataSource = FriendsDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addNotificationObservers()
        navigationController?.hidesBarsOnSwipe = true

        ElloHUD.showLoadingHud()
        let streamService = StreamService()
        streamService.loadFriendStream({ (activities) in
            ElloHUD.hideLoadingHud()
            self.activities = activities
            self.dataSource.viewController = self
            self.dataSource.activities = activities
            self.dataSource.viewController = self
            self.collectionView.dataSource = self.dataSource
            self.collectionView.reloadData()
        }, failure: { (error, statusCode) in
            ElloHUD.hideLoadingHud()
            println("failed to load friends stream")
        })
    }

    func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellHeightUpdated:", name: "UpdateHeightNotification", object: nil)
    }

    func cellHeightUpdated(notification:NSNotification) {
        if let cell = notification.object? as? StreamImageCell {
            if let indexPath = collectionView.indexPathForCell(cell) {
                dataSource.updateHeightForIndexPath(indexPath, height: cell.calculatedHeight)
                collectionView.reloadItemsAtIndexPaths([indexPath])
            }
        }
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

}
