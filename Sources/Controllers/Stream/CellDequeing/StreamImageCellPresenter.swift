//
//  StreamImageCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct StreamImageCellPresenter {
    private static let padding: CGFloat = 15

    static func preventImageStretching(cell: StreamImageCell, attachmentWidth: Int?, columnWidth: CGFloat, padding: CGFloat = 0) {
        if let attachmentWidth = attachmentWidth {
            let width = CGFloat(attachmentWidth)
            if width < columnWidth - padding * 2 {
                cell.imageLeftContraint?.constant = padding
                cell.imageRightConstraint?.constant = columnWidth - width - padding
            }
        }
    }

    static func configureRepostLayout(
        cell: StreamImageCell,
        streamCellItem: StreamCellItem)
    {
        // Repost specifics
        if streamCellItem.region?.isRepost == true {
            cell.leadingConstraint.constant = 30.0
            cell.showBorder()
        }
        else if let comment = streamCellItem.jsonable as? Comment {
            cell.leadingConstraint.constant = StreamTextCellPresenter.commentMargin
        }
        else {
            cell.leadingConstraint.constant = 0.0
        }
    }

    public static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamImageCell {
            if let imageRegion = streamCellItem.data as? ImageRegion {
                cell.imageLeftContraint?.constant = 0
                cell.imageRightConstraint?.constant = 0

                var attachmentToLoad: Attachment?
                var imageToLoad: NSURL?
                var showGifInThisCell = false
                if let asset = imageRegion.asset where asset.isGif {
                    if streamKind.supportsLargeImages || !asset.isLargeGif {
                        attachmentToLoad = asset.optimized
                        imageToLoad = asset.optimized?.url
                        showGifInThisCell = true
                    }
                    else {
                        cell.presentedImageUrl = asset.optimized?.url
                        cell.isLargeImage = true
                    }
                    cell.isGif = true
                }
                

                let columnWidth: CGFloat
                if streamKind.isGridLayout {
                    attachmentToLoad = attachmentToLoad ?? imageRegion.asset?.gridLayoutAttachment
                    columnWidth = (UIScreen.screenWidth() - CGFloat(10)) / 2
                }
                else {
                    attachmentToLoad = attachmentToLoad ?? imageRegion.asset?.oneColumnAttachment
                    columnWidth = UIScreen.screenWidth()
                }

                imageToLoad = imageToLoad ?? attachmentToLoad?.url
                
                preventImageStretching(cell, attachmentWidth: attachmentToLoad?.width, columnWidth: columnWidth)

                if let imageURL = imageToLoad {
                    cell.serverProvidedAspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
                    cell.isGif = imageURL.hasGifExtension
                    cell.setImage(imageURL, isGif: showGifInThisCell)
                }
                else if let imageURL = imageRegion.url {
                    cell.isGif = imageURL.hasGifExtension
                    cell.setImage(imageURL, isGif: imageURL.hasGifExtension)
                }

                cell.hideBorder()
                configureRepostLayout(cell, streamCellItem: streamCellItem)
            }
        }
    }
}
