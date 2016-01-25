//
//  DiscoverStreamPickerCellPresenter.swift
//  Ello
//
//  Created by Colin Gray on 1/7/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

public struct DiscoverStreamPickerCellPresenter {

    static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? DiscoverStreamPickerCell {
            cell.segmentedControl.setTitle(DiscoverType.Recommended.name, forSegmentAtIndex: 0)
            cell.segmentedControl.setTitle(DiscoverType.Trending.name, forSegmentAtIndex: 1)
            cell.segmentedControl.setTitle(DiscoverType.Recent.name, forSegmentAtIndex: 2)

            if case let .Discover(discoverType, _) = streamKind {
                cell.discoverType = discoverType
            }
            else {
                cell.discoverType = .Recommended
            }
        }
    }
}

