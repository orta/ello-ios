//
//  StreamEmbedCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct StreamEmbedCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamEmbedCell {
            if let embedData = streamCellItem.data as! EmbedRegion? {
                var photoToLoad: NSURL?
                if streamKind.isGridLayout {
                    photoToLoad = embedData.thumbnailSmallUrl
                }
                else {
                    photoToLoad = embedData.thumbnailLargeUrl
                }
                cell.embedUrl = embedData.url
                if embedData.isAudioEmbed {
                    cell.setPlayImageIcon("embetter_audio_play.svg")
                }
                else {
                    cell.setPlayImageIcon("embetter_video_play.svg")
                }

                if let photoURL = photoToLoad {
                    cell.setImage(photoURL, isGif: false)
                }
                cell.hideBorder()
                // Repost specifics
                if streamCellItem.region?.isRepost == true {
                    cell.leadingConstraint.constant = 30.0
                    cell.showBorder()
                }
                else {
                    cell.leadingConstraint.constant = 0.0
                }
            }
        }
    }

}
