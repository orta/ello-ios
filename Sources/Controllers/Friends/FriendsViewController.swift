//
//  FriendsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class FriendsViewController: BaseElloViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()        
        navigationController?.hidesBarsOnSwipe = true

        let streamService = StreamService()
        streamService.loadFriendStream({ (activities) in
            println(activities)
        }, failure: { (error, statusCode) in
            println("failed to load friends stream")
        })
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> FriendsViewController {
        return storyboard.controllerWithID(.Friends) as FriendsViewController
    }

    func setupCollectionView() {
//        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = true
//        collectionView.dataSource = self
    }

}
