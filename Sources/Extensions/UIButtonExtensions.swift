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

    func setSVGImages(named: String, rotation: Double = 0) {
        self.setSVGImage("\(named)_normal.svg", forState: UIControlState.Normal, rotation: rotation)
        self.setSVGImage("\(named)_selected.svg", forState: UIControlState.Selected, rotation: rotation)
    }

    func setSVGImage(named: String, forState state: UIControlState = UIControlState.Normal, rotation: Double = 0) {
        var withExtension = named
        if withExtension.rangeOfString(".svg") == nil {
            withExtension = withExtension + ".svg"
        }
        self.setImage(SVGKImage(named: withExtension).UIImage!, forState: state)
        if rotation > 0 {
            var radians = (rotation * M_PI) / 180.0
            self.transform = CGAffineTransformMakeRotation(CGFloat(radians))
        }
    }
}
