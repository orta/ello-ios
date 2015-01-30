//
//  ElloErrorLabel.swift
//  Ello
//
//  Created by Sean on 1/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class ElloErrorLabel: UILabel {

    func attributes(title:String) -> [NSObject : AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10

        var attributedString = NSMutableAttributedString(string: title)
        var range = NSRange(location: 0, length: countElements(title))
        return [
            NSFontAttributeName : UIFont.typewriterFont(12.0),
            NSForegroundColorAttributeName : UIColor.redColor(),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
    }

    func height() -> CGFloat {
        if let text = self.text {
            let nstext:NSString = NSString(string: text)
            return nstext.boundingRectWithSize(CGSize(width: self.frame.size.width, height: CGFloat.max),
                options: .UsesLineFragmentOrigin,
                attributes: attributes(text),
                context: nil).size.height
        }
        return 0.0
    }

    func setLabelText(title:String) {
        var attributedString = NSMutableAttributedString(string: title)
        var range = NSRange(location: 0, length: countElements(title))
        attributedString.addAttributes(attributes(title), range: range)
        self.attributedText = attributedString
    }

}
