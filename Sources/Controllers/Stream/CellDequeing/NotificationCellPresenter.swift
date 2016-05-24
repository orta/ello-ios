//
//  NotificationCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct NotificationCellPresenter {

    static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? NotificationCell,
            let notification = streamCellItem.jsonable as? Notification
        {
            cell.onWebContentReady { webView in
                if let actualHeight = webView.windowContentSize()?.height {
                    if actualHeight != streamCellItem.calculatedWebHeight {
                        StreamNotificationCellSizeCalculator.assignTotalHeight(actualHeight, cellItem: streamCellItem, cellWidth: cell.frame.width)
                        postNotification(StreamNotification.UpdateCellHeightNotification, value: cell)
                    }
                }
            }
            cell.onHeightMismatch = { _ in
                StreamNotificationCellSizeCalculator.assignTotalHeight(streamCellItem.calculatedWebHeight, cellItem: streamCellItem, cellWidth: cell.frame.width)
                postNotification(StreamNotification.UpdateCellHeightNotification, value: cell)
            }

            cell.title = notification.attributedTitle
            cell.createdAt = notification.createdAt
            cell.user = notification.author
            cell.canReplyToComment = notification.canReplyToComment
            cell.canBackFollow = notification.canBackFollow
            cell.post = notification.activity.subject as? Post
            cell.comment = notification.activity.subject as? ElloComment
            cell.messageHtml = notification.textRegion?.content

            if let imageRegion = notification.imageRegion {
                let aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
                var imageURL: NSURL?
                if let asset = imageRegion.asset where !asset.isGif {
                    imageURL = asset.optimized?.url
                }
                else if let hdpiURL = imageRegion.asset?.hdpi?.url{
                    imageURL = hdpiURL
                }
                else {
                    imageURL = imageRegion.url
                }
                cell.aspectRatio = aspectRatio
                cell.imageURL = imageURL
            }
        }
    }

}
