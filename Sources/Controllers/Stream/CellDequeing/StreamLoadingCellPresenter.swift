//
//  StreamLoadingCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct StreamLoadingCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? StreamLoadingCell {
            cell.start()
        }
    }

}