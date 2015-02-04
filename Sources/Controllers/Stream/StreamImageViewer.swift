//
//  StreamImageViewer.swift
//  Ello
//
//  Created by Sean on 1/27/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class StreamImageViewer: NSObject,
JTSImageViewControllerOptionsDelegate,
JTSImageViewControllerDismissalDelegate,
StreamImageCellDelegate {

    let controller:UIViewController

    init(controller:UIViewController) {
        self.controller = controller
    }

    func imageTapped(imageView:UIImageView) {
        let imageInfo = JTSImageInfo()
        imageInfo.image = imageView.image
        imageInfo.referenceRect = imageView.frame
        imageInfo.referenceView = imageView.superview
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOption.None)
        let transition:JTSImageViewControllerTransition = ._FromOriginalPosition
        imageViewer.showFromViewController(controller, transition: transition)
        imageViewer.optionsDelegate = self
        imageViewer.dismissalDelegate = self
    }

// MARK: JTSImageViewControllerOptionsDelegate

    func alphaForBackgroundDimmingOverlayInImageViewer(imageViewer: JTSImageViewController!) -> CGFloat {
        return 1.0
    }

// MARK: JTSImageViewControllerDismissalDelegate

    func imageViewerDidDismiss(imageViewer: JTSImageViewController!) {
    }

}
