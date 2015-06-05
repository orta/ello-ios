//
//  StreamImageViewer.swift
//  Ello
//
//  Created by Sean on 1/27/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import FLAnimatedImage
import JTSImageViewController

public class StreamImageViewer: NSObject,
JTSImageViewControllerOptionsDelegate,
JTSImageViewControllerDismissalDelegate,
JTSImageViewControllerAnimationDelegate,
StreamImageCellDelegate {

    let presentingController: StreamViewController
    let collectionView: UICollectionView
    let dataSource: StreamDataSource
    weak var imageView: UIImageView?
    var didFlick = false

    public init(presentingController: StreamViewController,
        collectionView: UICollectionView,
        dataSource: StreamDataSource)
    {
        self.presentingController = presentingController
        self.collectionView = collectionView
        self.dataSource = dataSource
    }

    public func imageTapped(imageView: FLAnimatedImageView, cell: StreamImageCell) {
        self.imageView = imageView
        imageView.hidden = true
        let imageInfo = JTSImageInfo()
        if let presentedUrl = cell.presentedImageUrl {
            imageInfo.imageURL = presentedUrl
        }
        else {
            imageInfo.image = imageView.image
        }
        imageInfo.referenceRect = imageView.frame
        imageInfo.referenceView = imageView.superview
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.None)
        let transition:JTSImageViewControllerTransition = ._FromOriginalPosition
        imageViewer.showFromViewController(presentingController, transition: transition)
        imageViewer.animationDelegate = self
        imageViewer.optionsDelegate = self
        imageViewer.dismissalDelegate = self

        didFlick = true
    }

// MARK: JTSImageViewControllerOptionsDelegate

    public func alphaForBackgroundDimmingOverlayInImageViewer(imageViewer: JTSImageViewController) -> CGFloat {
        return 1.0
    }

// MARK: JTSImageViewControllerDismissalDelegate

    public func imageViewerDidDismiss(imageViewer: JTSImageViewController) {}

    public func imageViewerWillDismiss(imageViewer: JTSImageViewController) {
        self.imageView?.hidden = false
    }

    public func imageViewerWillAnimateDismissal(imageViewer: JTSImageViewController, withContainerView containerView: UIView, duration: CGFloat) {
        didFlick = false
    }

}
