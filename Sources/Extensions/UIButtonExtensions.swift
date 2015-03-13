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

    func setSVGImage(named: String) {
        self.setImage(SVGKImage(named: "\(named)_normal.svg").UIImage!, forState: UIControlState.Normal)
        self.setImage(SVGKImage(named: "\(named)_selected.svg").UIImage!, forState: UIControlState.Selected)
    }
}