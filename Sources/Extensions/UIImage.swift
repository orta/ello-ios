//
//  UIImage.swift
//  Ello
//
//  Created by Colin Gray on 3/30/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public extension UIImage {

    class func scaleToWidth(image: UIImage, maxWidth: CGFloat = 1200.0) -> UIImage {
        var newImage = image
        if image.size.width > maxWidth {
            let origAspect = image.size.width / image.size.height
            let size = CGSizeMake(maxWidth, maxWidth / origAspect)
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            image.drawInRect(CGRect(origin: CGPointZero, size: size))
            newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return newImage
    }

    func copyWithCorrectOrientationAndSize() -> UIImage {
        if self.imageOrientation == .Up {
            return UIImage.scaleToWidth(self)
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.drawInRect(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage.scaleToWidth(image)
    }
}
