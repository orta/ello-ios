//
//  ElloTabBar.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public class ElloTabBar: UITabBar {

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.barTintColor = UIColor.whiteColor()
        self.tintColor = UIColor.blackColor()
        self.clipsToBounds = true
    }

    convenience init() {
        self.init(frame: CGRectZero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

}
