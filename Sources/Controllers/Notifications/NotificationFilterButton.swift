//
//  NotificationFilterButton.swift
//  Ello
//
//  Created by Colin Gray on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class NotificationFilterButton: UIButton {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.titleLabel?.font = UIFont.defaultFont()
        self.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        self.setTitleColor(UIColor.greyA(), forState: .Normal)
        self.setBackgroundImage(UIImage(named: "selected-pixel"), forState: .Selected)
        self.setBackgroundImage(UIImage(named: "unselected-pixel"), forState: .Normal)
    }

}
