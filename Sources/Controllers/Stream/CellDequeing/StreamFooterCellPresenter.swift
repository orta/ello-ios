//
//  StreamFooterCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


public enum InteractionVisibility: String {
    case SelectedAndDisabled = "SelectedAndDisabled"
    case SelectedAndEnabled = "SelectedAndEnabled"
    case Enabled = "Enabled"
    case Disabled = "Disabled"
    case NotAllowed = "NotAllowed"

    var isVisible: Bool { return self != .Disabled }
    var isEnabled: Bool { return self == .Enabled || self == .SelectedAndEnabled }
    var isSelected: Bool { return self == .SelectedAndDisabled || self == .SelectedAndEnabled }
}


public struct StreamFooterCellPresenter {

    public static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if  let cell = cell as? StreamFooterCell,
            let post = streamCellItem.jsonable as? Post
        {
            cell.indexPath = indexPath
            cell.close()
            configureDisplayCounts(cell, post: post, streamKind: streamKind)
            configureToolBarItems(cell, post: post, currentUser: currentUser, streamKind: streamKind)
            configureCommentControl(cell, streamCellItem: streamCellItem, streamKind: streamKind)
            configureGridSpecificLayout(cell, streamKind: streamKind)
        }
    }

    private static func configureToolBarItems(
        cell: StreamFooterCell,
        post: Post,
        currentUser: User?,
        streamKind: StreamKind)
    {
        cell.comments = post.commentsCount?.numberToHuman()

        var ownPost = currentUser?.id == post.authorId

        let repostingEnabled = post.author?.hasRepostingEnabled ?? true
        var repostVisibility: InteractionVisibility = .Enabled
        if post.reposted { repostVisibility = .SelectedAndDisabled }
        if !repostingEnabled { repostVisibility = .Disabled }
        else if ownPost { repostVisibility = .NotAllowed }

        let commentingEnabled = post.author?.hasCommentingEnabled ?? true
        let commentVisibility: InteractionVisibility = commentingEnabled ? .Enabled : .Disabled

        let sharingEnabled = post.author?.hasSharingEnabled ?? true
        let shareVisibility: InteractionVisibility = sharingEnabled ? .Enabled : .Disabled
        let deleteVisibility: InteractionVisibility = ownPost ? .Enabled : .Disabled

        let lovingEnabled = post.author?.hasLovesEnabled ?? true
        var loveVisibility: InteractionVisibility = .Enabled
        if post.loved { loveVisibility = .SelectedAndEnabled }
        if !lovingEnabled { loveVisibility = .Disabled }

        cell.updateToolbarItems(
            streamKind: streamKind,
            repostVisibility: repostVisibility,
            commentVisibility: commentVisibility,
            shareVisibility: shareVisibility,
            deleteVisibility: deleteVisibility,
            loveVisibility: loveVisibility
        )
    }

    private static func configureCommentControl(
        cell: StreamFooterCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind )
    {
        if streamKind.isDetail {
            cell.commentsOpened = true
            cell.commentsControl.selected = true
        }
        else {
            let isLoading = streamCellItem.state == .Loading
            let isExpanded = streamCellItem.state == .Expanded

            if isLoading {
                // this should be set via a custom accessor or method,
                // me thinks.
                // `StreamFooterCell.state = streamCellItem.state` ??
                cell.commentsControl.animate()
                cell.commentsControl.selected = true
            }
            else {
                cell.commentsControl.finishAnimation()

                if isExpanded {
                    cell.commentsControl.selected = true
                    cell.commentsOpened = true
                }
                else {
                    cell.commentsControl.selected = false
                    cell.commentsOpened = false
                    streamCellItem.state = .Collapsed
                }
            }
        }
    }

    private static func configureGridSpecificLayout(
        cell: StreamFooterCell,
        streamKind: StreamKind)
    {
        cell.scrollView.scrollEnabled = !streamKind.isGridLayout
        cell.chevronButton.hidden = streamKind.isGridLayout
    }

    private static func configureDisplayCounts(
        cell: StreamFooterCell,
        post: Post,
        streamKind: StreamKind)
    {
        if streamKind.isGridLayout {
            cell.views = ""
            cell.reposts = ""
            cell.loves = ""
        }
        else {
            cell.views = post.viewsCount?.numberToHuman()
            cell.reposts = post.repostsCount?.numberToHuman()
            cell.loves = post.lovesCount?.numberToHuman()
        }
    }
}
