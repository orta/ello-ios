//
//  FriendsDataSource.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class FriendsDataSource: NSObject, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: FriendsCell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendsCell", forIndexPath: indexPath) as FriendsCell

        cell.contentView.backgroundColor = UIColor.redColor()

        return cell
    }

}
