//
//  ElloEditableTextView.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class ElloEditableTextView: UITextView {
    override func awakeFromNib() {
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
