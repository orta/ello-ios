//
//  StreamFooterButton.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class StreamFooterButton: UIButton {

    func setButtonTitle(title:String?) {
        if let title = title {
            setButtonTitle(title, color: UIColor.elloLightGray(), forState: .Normal)
            setButtonTitle(title, color: UIColor.blackColor(), forState: .Highlighted)
            setButtonTitle(title, color: UIColor.blackColor(), forState: .Selected)
        }
    }

    private func setButtonTitle(title:String, color:UIColor, forState state:UIControlState) {
        var attributedString = NSMutableAttributedString(string: title)
        var range = NSRange(location: 0, length: countElements(title))
        var attributes = [
            NSFontAttributeName : UIFont.typewriterFont(12.0),
            NSForegroundColorAttributeName : color
        ]
        attributedString.addAttributes(attributes, range: range)
        self.setAttributedTitle(attributedString, forState: state)
    }

    private func sharedSetup() {
        self.backgroundColor = UIColor.clearColor()
        self.titleLabel?.numberOfLines = 1
        setButtonTitle(self.titleForState(.Normal))
    }
}
