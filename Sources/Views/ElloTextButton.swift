//
//  ElloTextButton.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class ElloTextButton: UIButton {

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        self.backgroundColor = UIColor.clearColor()
//        self.titleLabel?.font = UIFont.typewriterFont(14.0)
        self.titleLabel?.numberOfLines = 1
        self.setTitleColor(UIColor.elloLightGray(), forState: UIControlState.Normal)


        if let title = self.titleLabel?.text {
            var attributedString = NSMutableAttributedString(string: title)
            attributedString.addAttribute(NSFontAttributeName, value:UIFont.typewriterFont(14.0), range: NSRange(location: 0, length: countElements(title)))
            attributedString.addAttribute(NSUnderlineStyleAttributeName, value:1, range: NSRange(location: 0, length: countElements(title)))

            self.setAttributedTitle(attributedString, forState: UIControlState.Normal)
        }


//        (NSUnderlineStyleAttributeName value:@(1) range:NSMakeRange(4, 4)];

    }
}
