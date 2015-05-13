//
//  StreamSeeMoreCommentsCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 5/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct StreamSeeMoreCommentsCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamSeeMoreCommentsCell {
            let post = streamCellItem.jsonable as! Post
            cell.buttonContainer.hidden = post.commentsCount <= 25
        }
    }
    
}
