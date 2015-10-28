//
//  StreamRepostHeaderCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct StreamRepostHeaderCellPresenter {

    static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamRepostHeaderCell,
            post = streamCellItem.jsonable as? Post
        {
            if let author = post.author {
                cell.atName = author.atName
            }
            else {
                cell.atName = ""
            }
        }
    }
}
