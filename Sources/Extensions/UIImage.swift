//
//  UIImage.swift
//  Ello
//
//  Created by Colin Gray on 3/30/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension UIImage {

    func copyWithCorrectOrientation() -> UIImage {
        if self.imageOrientation == .Up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.drawInRect(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
