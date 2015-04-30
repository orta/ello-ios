//
//  ImageLabelAnimatable.swift
//  Ello
//
//  Created by Sean on 4/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

@objc
public protocol ImageLabelAnimatable {
    optional func animate()
    optional func finishAnimation()
    var selected: Bool { get set }
    var highlighted: Bool { get set }
    var view: UIView { get }
}
