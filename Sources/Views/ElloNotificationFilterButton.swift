//
//  ElloNotificationFilterButton.swift
//  Ello
//
//  Created by Colin Gray on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class ElloNotificationFilterButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.titleLabel!.font = UIFont.typewriterFont(12)
        self.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        self.setTitleColor(UIColor.elloUnselectedGray(), forState: .Normal)
        self.setBackgroundImage(UIImage(named: "selected-pixel"), forState: .Selected)
        self.setBackgroundImage(UIImage(named: "unselected-pixel"), forState: .Normal)
    }

}
