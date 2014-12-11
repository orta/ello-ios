//
//  StreamImageCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

class StreamImageCell: UICollectionViewCell, JTSImageViewControllerOptionsDelegate, JTSImageViewControllerDismissalDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var debugTextField: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    weak var viewController: UIViewController?

    var defaultAspectRatio:CGFloat = 4.0/3.0
    var aspectRatio:CGFloat = 4.0/3.0
    var calculatedHeight:CGFloat {
        get { return UIScreen.screenWidth() / self.aspectRatio }
    }

    func setImageURL(url:NSURL) {
        debugTextField.text = url.absoluteString

        self.imageView.sd_setImageWithURL(url, completed: {
            (image, error, type, url) -> Void in

            if error == nil && image != nil {

                self.aspectRatio = (image.size.width / image.size.height)

                NSNotificationCenter.defaultCenter().postNotificationName("UpdateHeightNotification", object: self)

                UIView.animateWithDuration(0.15, animations: {
                    self.contentView.alpha = 1.0
                    self.imageView.alpha = 1.0
                })
                self.debugTextField.alpha = 0.0
            }
            else {
                UIView.animateWithDuration(0.15, animations: {
                    self.aspectRatio = self.defaultAspectRatio
                    self.debugTextField.alpha = 1.0
                    self.contentView.alpha = 0.5
                    self.imageView.alpha = 1.0
                })

            }
        })
    }

    @IBAction func imageTapped(sender: UIButton) {

        if let vc = viewController {
            let imageInfo = JTSImageInfo()
            imageInfo.image = self.imageView.image
            imageInfo.referenceRect = self.imageView.frame
            imageInfo.referenceView = self.imageView.superview
//            self.imageView.alpha = 0.0
            let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOption.None)
            let transition:JTSImageViewControllerTransition = ._FromOriginalPosition
            imageViewer.showFromViewController(vc, transition: transition)
            imageViewer.optionsDelegate = self
            imageViewer.dismissalDelegate = self

        }
//        // Present the view controller.
//        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
    
    func alphaForBackgroundDimmingOverlayInImageViewer(imageViewer: JTSImageViewController!) -> CGFloat {
        return 1.0
    }

    func imageViewerDidDismiss(imageViewer: JTSImageViewController!) {
//        UIView.animateWithDuration(1.15, animations: {
//            self.imageView.alpha = 1.0
//        })
    }


//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
//        let attributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
//
//        var newBounds = attributes.bounds
//        newBounds.size.height = UIScreen.screenWidth() / self.aspectRatio
//        newBounds.size.width = UIScreen.screenWidth()
//        attributes.bounds = newBounds
////        let newSize = CGSize(width: UIScreen.screenWidth(), height: UIScreen.screenWidth() / self.aspectRatio )
////        var newFrame = attributes.frame
////        newFrame.size.height = newSize.height
////        newFrame.size.width = newSize.width
////        attributes.frame = newFrame
//        return attributes
//    }
//    
}
