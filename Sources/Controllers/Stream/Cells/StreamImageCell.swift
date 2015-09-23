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
import PINRemoteImage
import SVGKit
import Alamofire

public class StreamImageCell: StreamRegionableCell {

    @IBOutlet public weak var imageView: FLAnimatedImageView!
    @IBOutlet public weak var imageButton: UIButton!
    @IBOutlet public weak var circle: PulsingCircle!
    @IBOutlet public weak var failImage: UIImageView!
    @IBOutlet public weak var failBackgroundView: UIView!
    @IBOutlet public weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet public weak var failWidthConstraint: NSLayoutConstraint!
    @IBOutlet public weak var failHeightConstraint: NSLayoutConstraint!

    // not used in StreamEmbedCell
    @IBOutlet public weak var largeImagePlayButton: UIImageView?
    @IBOutlet weak var imageRightConstraint: NSLayoutConstraint?

    weak var streamImageCellDelegate: StreamImageCellDelegate?
    public var isGif = false
    var request: Request?
    public var tallEnoughForFailToShow = true
    public var presentedImageUrl: NSURL?
    var serverProvidedAspectRatio: CGFloat?
    public var isLargeImage: Bool {
        get { return !(largeImagePlayButton?.hidden ?? true) }
        set {
            largeImagePlayButton?.image = SVGKImage(named: "embetter_video_play.svg").UIImage
            largeImagePlayButton?.hidden = !newValue
        }
    }
    private let defaultAspectRatio: CGFloat = 4.0/3.0
    private var aspectRatio: CGFloat = 4.0/3.0

    var calculatedHeight: CGFloat {
        return self.frame.width / self.aspectRatio
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        if let playButton = largeImagePlayButton {
            playButton.image = SVGKImage(named: "embetter_video_play.svg").UIImage!
        }
    }

    public func setImageURL(url: NSURL) {
        imageView.image = nil
        imageView.alpha = 0
        circle.pulse()
        failImage.hidden = true
        failImage.alpha = 0
        imageView.backgroundColor = UIColor.whiteColor()
        loadImage(url)
    }

    public func setImage(image: UIImage) {
        imageView.pin_cancelImageDownload()
        imageView.image = image
        imageView.alpha = 0
        failImage.hidden = true
        failImage.alpha = 0
        imageView.backgroundColor = UIColor.whiteColor()
    }

    private func loadImage(url: NSURL) {
        self.imageView.pin_setImageFromURL(url) { result in
            let success = result.image != nil || result.animatedImage != nil
            let isAnimated = result.animatedImage != nil
            if success {
                self.aspectRatio = isAnimated ? (result.animatedImage.size.width / result.animatedImage.size.height) : (result.image.size.width / result.image.size.height)

                if self.serverProvidedAspectRatio == nil {
                    postNotification(StreamNotification.AnimateCellHeightNotification, value: self)
                }

                if result.resultType != .MemoryCache {
                    self.imageView.alpha = 0
                    UIView.animateWithDuration(0.3,
                        delay:0.0,
                        options:UIViewAnimationOptions.CurveLinear,
                        animations: {
                            self.imageView.alpha = 1.0
                        }, completion: { _ in
                            self.circle.stopPulse()
                        }
                    )
                }
                else {
                    self.imageView.alpha = 1.0
                    self.circle.stopPulse()
                }
            }
            else {
                self.imageLoadFailed()
            }
        }
    }

    private func imageLoadFailed() {
        imageButton.enabled = false
        failImage.hidden = false
        failBackgroundView.hidden = false
        circle.stopPulse()
        aspectRatio = self.defaultAspectRatio
        largeImagePlayButton?.hidden = true
        nextTick { postNotification(StreamNotification.AnimateCellHeightNotification, value: self) }
        UIView.animateWithDuration(0.15) {
            self.failImage.alpha = 1.0
            self.imageView.backgroundColor = UIColor.greyF1()
            self.failBackgroundView.backgroundColor = UIColor.greyF1()
            self.imageView.alpha = 1.0
            self.failBackgroundView.alpha = 1.0
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        imageButton.enabled = true
        request?.cancel()
        imageView.image = nil
        imageView.animatedImage = nil
        imageView.pin_cancelImageDownload()

        isGif = false
        presentedImageUrl = nil
        isLargeImage = false
        failImage.hidden = true
        failImage.alpha = 0
        failBackgroundView.hidden = true
        failBackgroundView.alpha = 0
    }

    @IBAction func imageTapped(sender: UIButton) {
        streamImageCellDelegate?.imageTapped(self.imageView, cell: self)
    }
}
