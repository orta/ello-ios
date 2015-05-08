//
//  ElloTabBar.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public class ElloTabBar: UITabBar {
    struct Size {
        static let height = CGFloat(49)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        privateInit()
    }

    convenience init() {
        self.init(frame: CGRectZero)
        privateInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    private func privateInit() {
        self.backgroundColor = UIColor.whiteColor()
        self.translucent = false
        self.opaque = true
        self.barTintColor = UIColor.whiteColor()
        self.tintColor = UIColor.blackColor()
        self.clipsToBounds = true
        self.shadowImage = UIImage.imageWithColor(UIColor.whiteColor())
    }

}
