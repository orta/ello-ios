//
//  UIImage.swift
//  Ello
//
//  Created by Colin Gray on 3/30/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public extension UIImage {

    class func scaleToMaxSize(image: UIImage, maxSize: CGSize = CGSize(width: 1200.0, height: 3600.0)) -> UIImage {
        var newImage = image
        var newSize = image.size
        if newSize.width > maxSize.width {
            let scale = maxSize.width / newSize.width
            newSize = CGSizeMake(newSize.width * scale, newSize.height * scale)
        }
        if newSize.height > maxSize.height {
            let scale = maxSize.height / newSize.height
            newSize = CGSizeMake(newSize.width * scale, newSize.height * scale)
        }

        if newSize != image.size {
            UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
            image.drawInRect(CGRect(origin: CGPointZero, size: newSize))
            newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        return newImage
    }

    func copyWithCorrectOrientationAndSize(completion:(image: UIImage) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let resizedImage: UIImage
            if self.imageOrientation == .Up {
                resizedImage = UIImage.scaleToMaxSize(self)
            }
            else {
                UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
                self.drawInRect(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                resizedImage = UIImage.scaleToMaxSize(image)
            }

            nextTick {
                completion(image: resizedImage)
            }
        }
    }
}
