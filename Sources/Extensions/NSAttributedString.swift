//
//  NSAttributedString.swift
//  Ello
//
//  Created by Sean on 4/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func widthForHeight(height: CGFloat) -> CGFloat {
        return ceil(boundingRectWithSize(CGSize(width: CGFloat.max, height: height),
            options: [.UsesLineFragmentOrigin, .UsesFontLeading],
            context: nil).size.width)
    }

    func joinWithNewlines(other: NSAttributedString) -> NSAttributedString {
        let retVal = NSMutableAttributedString(attributedString: self)
        if other.string.characters.count > 0 {
            if self.string.characters.count > 0 {
                if !self.string.endsWith("\n") {
                    retVal.appendAttributedString(ElloAttributedString.style("\n\n"))
                }
                else if !self.string.endsWith("\n\n") {
                    retVal.appendAttributedString(ElloAttributedString.style("\n"))
                }
            }

            retVal.appendAttributedString(other)
        }

        return retVal
    }
}
