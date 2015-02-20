//
//  NotificationCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct NotificationCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? NotificationCell {
            var notification = streamCellItem.jsonable as Notification
            var user = notification.author!

            cell.title = notification.attributedTitle
            cell.createdAt = notification.createdAt
            cell.avatarURL = user.avatarURL
            cell.imageURL = nil
            cell.messageHtml = nil

            if let textRegion = notification.textRegion {
                cell.messageHtml = textRegion.content
            }

            if let imageRegion = notification.imageRegion {
                var aspectRatio = StreamCellItemParser.aspectRatioForImageBlock(imageRegion)
                if let photoURL = imageRegion.asset?.hdpi?.url? {
                    cell.aspectRatio = aspectRatio
                    cell.imageURL = photoURL
                }
                else if let photoURL = imageRegion.url {
                    cell.aspectRatio = aspectRatio
                    cell.imageURL = photoURL
                }
            }
        }
    }

}