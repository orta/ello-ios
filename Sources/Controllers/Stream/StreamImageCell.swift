//
//  StreamImageCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

class StreamImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var debugTextField: UITextField!
    @IBOutlet weak var imageButton: UIButton!

    let defaultAspectRatio:CGFloat = 4.0/3.0
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
        NSNotificationCenter.defaultCenter().postNotificationName("ImageTappedNotification", object: self.imageView)
    }
    
}
