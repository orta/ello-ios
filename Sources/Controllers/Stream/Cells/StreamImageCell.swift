//
//  StreamImageCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation
import FLAnimatedImage
import SDWebImage

let updateStreamImageCellHeightNotification = TypedNotification<StreamImageCell>(name: "updateStreamImageCellHeightNotification")

public class StreamImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var errorLabel: ElloErrorLabel!
    @IBOutlet weak var circle:PulsingCircle!
    @IBOutlet weak var imageLeftContraint: NSLayoutConstraint!
    @IBOutlet weak var imageRightConstraint: NSLayoutConstraint!

    weak var delegate: StreamImageCellDelegate?
    var serverProvidedAspectRatio:CGFloat?
    private let defaultAspectRatio:CGFloat = 4.0/3.0
    private var aspectRatio:CGFloat = 4.0/3.0

    var calculatedHeight:CGFloat {
        return self.frame.width / self.aspectRatio
    }

    func setImageURL(url:NSURL) {
        self.imageView.image = nil
        self.imageView.alpha = 0
        circle.pulse()
        self.errorLabel.hidden = true
        self.errorLabel.alpha = 1.0
        self.imageView.backgroundColor = UIColor.whiteColor()
        self.errorLabel.alpha = 0
        self.imageView.sd_setImageWithURL(url, completed: {
            (image, _, type, _) in

            if let image = image {

                self.aspectRatio = (image.size.width / image.size.height)

                if self.serverProvidedAspectRatio == nil {
                    postNotification(updateStreamImageCellHeightNotification, self)
                }
                if type != .Memory {
                    self.imageView.alpha = 0
                    UIView.animateWithDuration(0.3,
                        delay:0.0,
                        options:UIViewAnimationOptions.CurveLinear,
                        animations: {
                            self.imageView.alpha = 1.0
                        }, completion: { finished in
                            self.circle.stopPulse()
                        })
                }
                else {
                    self.imageView.alpha = 1.0
                    self.circle.stopPulse()
                }
            }
            else {
                self.errorLabel.hidden = false
                self.errorLabel.setLabelText("Failed to load image")
                self.circle.stopPulse()
                UIView.animateWithDuration(0.15) {
                    self.aspectRatio = self.defaultAspectRatio
                    self.errorLabel.alpha = 1.0
                    self.imageView.backgroundColor = UIColor.greyA()
                    self.imageView.alpha = 1.0
                }

            }
        })
    }

    @IBAction func imageTapped(sender: UIButton) {
         delegate?.imageTapped(self.imageView, cell: self)
    }
}
