//
//  StreamImageCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

protocol StreamImageCellDelegate : NSObjectProtocol {
    func imageTapped(imageView:UIImageView)
}

let updateStreamImageCellHeightNotification = TypedNotification<StreamImageCell>(name: "updateStreamImageCellHeightNotification")

class StreamImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageButton: UIButton!

    weak var delegate: StreamImageCellDelegate?
    var serverProvidedAspectRatio:CGFloat?
    private let defaultAspectRatio:CGFloat = 4.0/3.0
    private var aspectRatio:CGFloat = 4.0/3.0
    private var circle:PulsingCircle!

    override func awakeFromNib() {
        super.awakeFromNib()
        circle = PulsingCircle.fill(self)
        contentView.insertSubview(circle!, belowSubview: imageView)
    }

    var calculatedHeight:CGFloat {
        return UIScreen.screenWidth() / self.aspectRatio
    }

    func setImageURL(url:NSURL) {
        circle.pulse()

        self.imageView.sd_setImageWithURL(url, completed: {
            (image, error, type, url) in

            if error == nil && image != nil {

                self.aspectRatio = (image.size.width / image.size.height)

                if self.serverProvidedAspectRatio == nil {
                    postNotification(updateStreamImageCellHeightNotification, self)
                }

                UIView.animateWithDuration(0.15,
                    delay:0.0,
                    options:UIViewAnimationOptions.CurveLinear,
                    animations: {
                        self.contentView.alpha = 1.0
                        self.imageView.alpha = 1.0
                    }, completion: { finished in
                        self.circle.stopPulse()
                    })
            }
            else {
                UIView.animateWithDuration(0.15, animations: {
                    self.aspectRatio = self.defaultAspectRatio
                    self.contentView.alpha = 0.5
                    self.imageView.alpha = 1.0
                })

            }
        })

    }

    @IBAction func imageTapped(sender: UIButton) {
        delegate?.imageTapped(self.imageView)
//        NSNotificationCenter.defaultCenter().postNotificationName("ImageTappedNotification", object: self.imageView)
    }

}
