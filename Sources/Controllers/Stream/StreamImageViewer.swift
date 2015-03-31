//
//  StreamImageViewer.swift
//  Ello
//
//  Created by Sean on 1/27/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import FLAnimatedImage

class StreamImageViewer: NSObject,
JTSImageViewControllerOptionsDelegate,
JTSImageViewControllerDismissalDelegate,
StreamImageCellDelegate {

    let presentingController: StreamViewController
    let collectionView: UICollectionView
    let dataSource: StreamDataSource

    init(presentingController: StreamViewController,
        collectionView: UICollectionView,
        dataSource: StreamDataSource)
    {
        self.presentingController = presentingController
        self.collectionView = collectionView
        self.dataSource = dataSource
    }

    func imageTapped(imageView: FLAnimatedImageView, cell: UICollectionViewCell) {
        if presentingController.streamKind.isGridLayout {
            postTappedForCell(cell)
        }
        else {
            showImageView(imageView)
        }
    }

    private func showImageView(imageView: FLAnimatedImageView) {
        let imageInfo = JTSImageInfo()
        imageInfo.image = imageView.image
        imageInfo.referenceRect = imageView.frame
        imageInfo.referenceView = imageView.superview
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOption.None)
        let transition:JTSImageViewControllerTransition = ._FromOriginalPosition
        imageViewer.showFromViewController(presentingController, transition: transition)
        imageViewer.optionsDelegate = self
        imageViewer.dismissalDelegate = self
    }

    private func postTappedForCell(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let post = dataSource.postForIndexPath(indexPath) {
                let items = self.dataSource.cellItemsForPost(post)
                // This is a bit dirty, we should not call a method on a compositionally held
                // controller's postTappedDelegate. Need to chat about this with the crew.
                presentingController.postTappedDelegate?.postTapped(post, initialItems: items)
            }
        }
    }

// MARK: JTSImageViewControllerOptionsDelegate

    func alphaForBackgroundDimmingOverlayInImageViewer(imageViewer: JTSImageViewController!) -> CGFloat {
        return 1.0
    }

// MARK: JTSImageViewControllerDismissalDelegate

    func imageViewerDidDismiss(imageViewer: JTSImageViewController!) {
    }

}
