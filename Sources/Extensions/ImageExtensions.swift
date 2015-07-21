//
//  ImageExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/9/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public extension UIImage {

    class func imageWithColor(color:UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
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

    func squareImageToSize(size: CGSize) -> UIImage? {
        return self.squareImage()?.resizeToSize(size)
    }

    func squareImage() -> UIImage? {
        var originalWidth  = self.size.width
        var originalHeight = self.size.height

        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }

        var posX = (originalWidth  - edge) / 2.0
        var posY = (originalHeight - edge) / 2.0

        var cropSquare = CGRectMake(posX, posY, edge, edge)

        var imageRef = CGImageCreateWithImageInRect(self.CGImage, cropSquare);
        return UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: self.imageOrientation)
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
            if self.imageOrientation == .Up {
                sourceImage = self
            }
            else {
                UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
                self.drawInRect(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
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


