//
//  NotificationCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct NotificationCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
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
                        postNotification(StreamNotification.UpdateCellHeightNotification, cell)
                    }
                }
            }

            cell.title = notification.attributedTitle
            cell.createdAt = notification.createdAt
            if let user = notification.author {
                cell.avatarURL = user.avatarURL
            }
            else {
                cell.avatarURL = nil
            }
            cell.imageURL = nil
            cell.messageHtml = nil

            if let textRegion = notification.textRegion {
                let content = textRegion.content
                cell.messageHtml = content
            }

            if let imageRegion = notification.imageRegion {
                var aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
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
                cell.imageURL = imageURL
                cell.aspectRatio = aspectRatio
            }
        }
    }

}
