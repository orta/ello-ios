//
//  ImageLabelAnimatable.swift
//  Ello
//
//  Created by Sean on 4/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
public protocol ImageLabelAnimatable {
    optional func animate()
    optional func finishAnimation()
    var enabled: Bool { get set }
    var selected: Bool { get set }
    var highlighted: Bool { get set }
    var view: UIView { get }
}
