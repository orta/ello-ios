//
//  NotificationCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct NotificationCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? NotificationCell {
            var notification = streamCellItem.jsonable as! Notification

            cell.onWebContentReady { webView in
                if let actualHeight = webView.windowContentSize()?.height {
                    if actualHeight != streamCellItem.calculatedWebHeight {
                        StreamNotificationCellSizeCalculator.assignTotalHeight(actualHeight, cellItem: streamCellItem, cellWidth: cell.frame.width)
                        postNotification(RelayoutStreamViewControllerNotification, cell)
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
                var aspectRatio = StreamCellItemParser.aspectRatioForImageBlock(imageRegion)
                var imageURL: NSURL?
                if imageRegion.asset != nil && imageRegion.asset!.isGif {
                    imageURL = imageRegion.asset?.optimized?.url
                }
                else {
                    imageURL = imageRegion.asset?.hdpi?.url
                }
                cell.imageURL = imageURL ?? imageRegion.url
                cell.aspectRatio = aspectRatio
            }
        }
    }

}
