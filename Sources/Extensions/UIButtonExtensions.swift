//
//  UIButtonExtensions.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SVGKit

extension UIButton {

    func setSVGImages(named: String, degree: Double = 0) {
        self.setSVGImage("\(named)_normal.svg", forState: .Normal, degree: degree)
        self.setSVGImage("\(named)_selected.svg", forState: .Selected, degree: degree)
    }

    func setSVGImage(var named: String, forState state: UIControlState = .Normal, degree: Double = 0) {
        if named.rangeOfString(".svg") == nil {
            named = named + ".svg"
        }
        self.setImage(SVGKImage(named: named).UIImage!, forState: state)
        if degree != 0 {
            var radians = (degree * M_PI) / 180.0
            self.transform = CGAffineTransformMakeRotation(CGFloat(radians))
        }
    }
}
