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
            if case let .Discover(discoverType, _) = streamKind {
                cell.discoverType = discoverType
            }
            else {
                cell.discoverType = .Recommended
            }
        }
    }
}

