//
//  ElloEditableTextView.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class ElloEditableTextView: UITextView {
    required override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        sharedSetup()
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    func sharedSetup() {
        backgroundColor = UIColor.greyE5()
        font = UIFont.typewriterFont(12.0)
        textColor = UIColor.blackColor()
        contentInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 15.0)
        scrollsToTop = false
        setNeedsDisplay()
    }
}
