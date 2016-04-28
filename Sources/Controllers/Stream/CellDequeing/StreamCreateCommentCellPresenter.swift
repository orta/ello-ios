//
//  StreamCreateCommentCellPresenter.swift
//  Ello
//
//  Created by Colin Gray on 3/10/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct StreamCreateCommentCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamCreateCommentCell,
            comment = streamCellItem.jsonable as? ElloComment,
            post = comment.loadedFromPost,
            user = comment.author
        {
            let ownPost = currentUser?.id == post.authorId
            let replyAllVisibility: InteractionVisibility = ownPost ? .Enabled : .Hidden

            cell.indexPath = indexPath
            cell.avatarURL = user.avatarURL
            cell.replyAllVisibility = replyAllVisibility
        }
    }

}
