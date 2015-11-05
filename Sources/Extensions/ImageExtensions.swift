//
//  ImageExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/9/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public extension UIImage {

    class func imageWithColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    class func imageWithHex(hex: Int) -> UIImage {
        return imageWithColor(UIColor(hex: hex))
    }

    func squareImage() -> UIImage? {
        let originalWidth  = self.size.width
        let originalHeight = self.size.height

        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }

        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0

        let cropSquare = CGRectMake(posX, posY, edge, edge)

        let imageRef = CGImageCreateWithImageInRect(self.CGImage, cropSquare)
        if let imageRef = imageRef {
            return UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: self.imageOrientation)
        }
        return nil
    }

    func resizeToSize(targetSize: CGSize) -> UIImage {
        let newSize = self.size.scaledSize(targetSize)

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func roundCorners() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRectMake(0.0, 0.0, self.size.width, self.size.height)
        UIBezierPath(roundedRect: rect, cornerRadius: size.width / 2.0).addClip()
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func copyWithCorrectOrientationAndSize(completion:(image: UIImage) -> Void) {
        inBackground {
            let sourceImage: UIImage
            if self.imageOrientation == .Up && self.scale == 1.0 {
                sourceImage = self
            }
            else {
                let newSize = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
                UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                self.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                sourceImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }

            let maxSize = CGSize(width: 1200.0, height: 3600.0)
            let resizedImage = sourceImage.resizeToSize(maxSize)
            inForeground {
                completion(image: resizedImage)
            }
        }
    }

}


