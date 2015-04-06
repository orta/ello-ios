//
//  ElloLabel.swift
//  Ello
//
//  Created by Sean on 3/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


public class ElloLabel: UILabel {
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let text = self.text {
            self.setLabelText(text, color: textColor)
        }
    }

    func attributes(title: String, color: UIColor) -> [NSObject : AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10

        var attributedString = NSMutableAttributedString(string: title)
        var range = NSRange(location: 0, length: count(title))
        return [
            NSFontAttributeName : UIFont.typewriterFont(12.0),
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle
        ]
    }

    func height() -> CGFloat {
        if let text = self.text {
            let nstext:NSString = NSString(string: text)
            return nstext.boundingRectWithSize(CGSize(width: self.frame.size.width, height: CGFloat.max),
                options: .UsesLineFragmentOrigin,
                attributes: attributes(text, color: UIColor.whiteColor()),
                context: nil).size.height
        }
        return 0.0
    }

    func setLabelText(title: String, color: UIColor = UIColor.whiteColor()) {
        var attributedString = NSMutableAttributedString(string: title)
        var range = NSRange(location: 0, length: count(title))
        attributedString.addAttributes(attributes(title, color: color), range: range)
        self.attributedText = attributedString
    }
}

public class ElloToggleLabel: ElloLabel {
    override func setLabelText(title: String, color: UIColor = UIColor.greyA()) {
        super.setLabelText(title, color: color)
    }
}

public class ElloErrorLabel: ElloLabel {
    override func setLabelText(title: String, color: UIColor = UIColor.redColor()) {
        super.setLabelText(title, color: color)
    }
}
