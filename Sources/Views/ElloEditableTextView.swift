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

        setNeedsDisplay()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textViewDidBeginEditing:"), name: UITextViewTextDidBeginEditingNotification, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textViewDidEndEditing:"), name: UITextViewTextDidEndEditingNotification, object: .None)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func textViewDidBeginEditing(notification: NSNotification) {
        if let textView = notification.object as? UITextView {
            if textView == self {
                UIView.animateWithDuration(0.2) {
                    self.backgroundColor = UIColor.whiteColor()
                }
            }
        }
    }

    func textViewDidEndEditing(notification: NSNotification) {
        if let textView = notification.object as? UITextView {
            if textView == self {
                UIView.animateWithDuration(0.2) {
                    self.backgroundColor = UIColor.greyE5()
                }
            }
        }
    }
}
