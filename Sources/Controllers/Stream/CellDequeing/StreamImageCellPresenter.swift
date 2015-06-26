//
//  StreamImageCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct StreamImageCellPresenter {

    static let singleColumnFailWidth: CGFloat = 140
    static let singleColumnFailHeight: CGFloat = 160
    static let multiColumnFailWidth: CGFloat = 70
    static let multiColumnFailHeight: CGFloat = 80

    static func preventImageStretching(cell: StreamImageCell, attachmentWidth: Int?, columnWidth: CGFloat, leftMargin: CGFloat = 0) {
        if let attachmentWidth = attachmentWidth {
            let width = CGFloat(attachmentWidth)
            if width < columnWidth - leftMargin {
                cell.imageRightConstraint?.constant = columnWidth - width - leftMargin
            }
        }
    }

    static func configureCellWidthAndLayout(
        cell: StreamImageCell,
        streamCellItem: StreamCellItem) -> CGFloat
    {
        // Repost specifics
        if streamCellItem.region?.isRepost == true {
            cell.leadingConstraint.constant = StreamTextCellPresenter.repostMargin
            cell.showBorder()
        }
        else if let comment = streamCellItem.jsonable as? Comment {
            cell.leadingConstraint.constant = StreamTextCellPresenter.commentMargin
        }
        else {
            cell.leadingConstraint.constant = 0.0
        }

        return cell.leadingConstraint.constant
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
                cell.imageRightConstraint?.constant = 0
                cell.failImage.hidden = true
                cell.failImage.alpha = 0
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
                    cell.failWidthConstraint.constant = StreamImageCellPresenter.multiColumnFailWidth
                    cell.failHeightConstraint.constant = StreamImageCellPresenter.multiColumnFailHeight
                    attachmentToLoad = attachmentToLoad ?? imageRegion.asset?.gridLayoutAttachment
                    columnWidth = (UIScreen.screenWidth() - CGFloat(10)) / 2
                }
                else {
                    cell.failWidthConstraint.constant = StreamImageCellPresenter.singleColumnFailWidth
                    cell.failHeightConstraint.constant = StreamImageCellPresenter.singleColumnFailHeight
                    attachmentToLoad = attachmentToLoad ?? imageRegion.asset?.oneColumnAttachment
                    columnWidth = UIScreen.screenWidth()
                }

                let imageToShow = attachmentToLoad?.image
                imageToLoad = imageToLoad ?? attachmentToLoad?.url

                cell.hideBorder()
                let margin = configureCellWidthAndLayout(cell, streamCellItem: streamCellItem)
                preventImageStretching(cell, attachmentWidth: attachmentToLoad?.width, columnWidth: columnWidth, leftMargin: margin)

                if let image = imageToShow where !showGifInThisCell {
                    cell.setImage(image)
                }
                else if let imageURL = imageToLoad {
                    cell.serverProvidedAspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
                    cell.setImage(imageURL, isGif: showGifInThisCell)
                }
                else if let imageURL = imageRegion.url {
                    cell.isGif = imageURL.hasGifExtension
                    cell.setImage(imageURL, isGif: imageURL.hasGifExtension)
                }
            }
        }
    }
}
