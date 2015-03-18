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

    func setSVGImages(named: String) {
        self.setSVGImage("\(named)_normal.svg", forState: UIControlState.Normal)
        self.setSVGImage("\(named)_selected.svg", forState: UIControlState.Selected)
    }

    func setSVGImage(named: String, forState state: UIControlState = UIControlState.Normal) {
        var withExtension = named
        if withExtension.rangeOfString(".svg") == nil {
            withExtension = withExtension + ".svg"
        }
        self.setImage(SVGKImage(named: withExtension).UIImage!, forState: state)
    }
}

