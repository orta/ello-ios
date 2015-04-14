//
//  ElloToggleButton.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class ElloToggleButton: UIButton {
    private let attributes = [NSFontAttributeName: UIFont.typewriterFont(14.0)]

    var value: Bool = false {
        didSet {
            toggleButton()
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.greyA().CGColor
        layer.borderWidth = 1

        setTitleColor(UIColor.greyA(), forState: .Normal)
    }

    private func setText(text: String, color: UIColor = UIColor.greyA()) {
        let string = NSMutableAttributedString(string: text, attributes: attributes)
        string.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location: 0, length: string.length))
        setAttributedTitle(string, forState: .Normal)
    }

    private func toggleButton() {
        backgroundColor = value ? UIColor.greyA() : UIColor.whiteColor()
        setText(value ? "Yes" : "No", color: value ? .whiteColor() : .greyA())
    }
}
