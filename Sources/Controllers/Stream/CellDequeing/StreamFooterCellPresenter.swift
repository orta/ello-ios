//
//  StreamFooterCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


public enum InteractionVisibility: String {
    case Enabled = "Enabled"
    case Disabled = "Disabled"
    case NotAllowed = "NotAllowed"

    var isVisible: Bool { return self != .Disabled }
    var isEnabled: Bool { return self == .Enabled }
}


public struct StreamFooterCellPresenter {

    public static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamFooterCell {
            cell.close()
            if let post = streamCellItem.jsonable as? Post {
                cell.comments = post.commentsCount?.localizedStringFromNumber()

                var ownPost = false
                if let currentUser = currentUser {
                    if post.authorId == currentUser.id {
                        ownPost = true
                    }
                }

                let repostingEnabled = post.author?.hasRepostingEnabled ?? true

                let repostVisibility: InteractionVisibility
                if !repostingEnabled {
                    repostVisibility = .Disabled
                }
                else if ownPost {
                    repostVisibility = .NotAllowed
                }
                else {
                    repostVisibility = .Enabled
                }

                let commentingEnabled = post.author?.hasCommentingEnabled ?? true
                let commentVisibility: InteractionVisibility = commentingEnabled ? .Enabled : .Disabled

                let sharingEnabled = post.author?.hasSharingEnabled ?? true
                let shareVisibility: InteractionVisibility = sharingEnabled ? .Enabled : .Disabled
                let deleteVisibility: InteractionVisibility = ownPost ? .Enabled : .Disabled

                cell.updateToolbarItems(
                    streamKind: streamKind,
                    repostVisibility: repostVisibility,
                    commentVisibility: commentVisibility,
                    shareVisibility: shareVisibility,
                    deleteVisibility: deleteVisibility
                    )

                if streamKind.isDetail {
                    cell.commentsControl.selected = true
                    cell.commentsOpened = true
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

                cell.scrollView.scrollEnabled = !streamKind.isGridLayout
                cell.chevronButton.hidden = streamKind.isGridLayout

                if streamKind.isGridLayout {
                    cell.views = ""
                    cell.reposts = ""
                }
                else {
                    cell.views = post.viewsCount?.numberToHuman()
                    cell.reposts = post.repostsCount?.numberToHuman()
                }
            }
        }
    }
}
