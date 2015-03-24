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
                var imageURL: NSURL
                if let isGif = imageRegion.asset?.optimized?.url? {
                    cell.imageURL = imageRegion.asset?.optimized?.url ?? imageRegion.url
                }
                else {
                    cell.imageURL = imageRegion.asset?.hdpi?.url ?? imageRegion.url
                }
                cell.aspectRatio = aspectRatio
            }
        }
    }

}
