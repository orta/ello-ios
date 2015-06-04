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
import SVGKit
import Alamofire

public class StreamImageCell: StreamRegionableCell {

    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var errorLabel: ElloErrorLabel!
    @IBOutlet weak var circle:PulsingCircle!
    @IBOutlet weak var leadingConstraint:NSLayoutConstraint!

    // not used in StreamEmbedCell
    @IBOutlet public weak var largeImagePlayButton: UIImageView?
    @IBOutlet weak var imageRightConstraint: NSLayoutConstraint?

    weak var streamImageCellDelegate: StreamImageCellDelegate?
    public var isGif = false
    var request: Request?
    public var presentedImageUrl:NSURL?
    var serverProvidedAspectRatio:CGFloat?
    public var isLargeImage: Bool {
        get { return !(largeImagePlayButton?.hidden ?? true) }
        set {
            largeImagePlayButton?.image = SVGKImage(named: "embetter_video_play.svg").UIImage
            largeImagePlayButton?.hidden = !newValue
        }
    }
    private let defaultAspectRatio:CGFloat = 4.0/3.0
    private var aspectRatio:CGFloat = 4.0/3.0

    var calculatedHeight:CGFloat {
        return self.frame.width / self.aspectRatio
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        if let playButton = largeImagePlayButton {
            playButton.image = SVGKImage(named: "embetter_video_play.svg").UIImage!
        }
    }

    public func setImage(url: NSURL, isGif: Bool) {
        self.imageView.image = nil
        self.imageView.alpha = 0
        circle.pulse()
        self.errorLabel.hidden = true
        self.errorLabel.alpha = 0
        self.imageView.backgroundColor = UIColor.whiteColor()
        isGif ? loadGif(url) : loadNonGif(url)
    }

    private func loadGif(url:NSURL) {
        if let path = url.absoluteString {
            if let data = GifCache.objectForKey(path) as? NSData {
                self.displayAnimatedGif(data)
            }
            else {
                self.request = Alamofire.request(.GET, path).response { (request, _, data, error) in
                    if let data = data as? NSData where error == nil {
                        GifCache.setObject(data, forKey: request.URLString)
                        self.displayAnimatedGif(data)
                    }
                }
            }
        }
    }

    private func displayAnimatedGif(data: NSData) {
        if let animatedImage = FLAnimatedImage(animatedGIFData: data) {
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.alpha = 1.0
                self.aspectRatio = (animatedImage.size.width / animatedImage.size.height)
                self.imageView.animatedImage = animatedImage
                self.circle.stopPulse()
            }
        }
    }

    private func loadNonGif(url:NSURL) {
        self.imageView.sd_setImageWithURL(url) { (image, _, type, _) in
            if let image = image {
                self.aspectRatio = (image.size.width / image.size.height)
                if self.serverProvidedAspectRatio == nil {
                    postNotification(StreamNotification.AnimateCellHeightNotification, self)
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
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        request?.cancel()
        imageView.image = nil
        isGif = false
        presentedImageUrl = nil
        isLargeImage = false
    }

    @IBAction func imageTapped(sender: UIButton) {
        streamImageCellDelegate?.imageTapped(self.imageView, cell: self)
    }
}
