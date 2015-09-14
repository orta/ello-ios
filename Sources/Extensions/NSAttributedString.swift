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
}
