//
//  FollowAllCellPresenter.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct FollowAllCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? FollowAllCell,
            let (userCount, followedCount) = streamCellItem.data as? (Int, Int)
        {
            cell.userCount = userCount
            cell.followedCount = followedCount
        }
    }

}
