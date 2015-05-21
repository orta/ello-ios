//
//  UIImageViewExtensions.swift
//  Ello
//
//  Created by Colin Gray on 5/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SVGKit

extension UIImageView {

    func setSVGImage(var named: String, degree: Double = 0) {
        if named.rangeOfString(".svg") == nil {
            named = named + ".svg"
        }
        if let image = SVGKImage(named: named).UIImage {
            self.image = image
            if degree != 0 {
                var radians = (degree * M_PI) / 180.0
                self.transform = CGAffineTransformMakeRotation(CGFloat(radians))
            }
        }
        else {
            println("there is no SVG asset called “\(named)”")
        }
    }

}
