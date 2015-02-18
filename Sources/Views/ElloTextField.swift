//
//  ElloTextField.swift
//  Ello
//
//  Created by Sean Dougherty on 11/25/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class ElloTextField: UITextField {

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func sharedSetup() {

        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("textDidBeginEditing:"), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        center.addObserver(self, selector: Selector("textDidEndEditing:"), name: UITextFieldTextDidEndEditingNotification, object: nil)

        self.backgroundColor = UIColor.greyE5()
        self.font = UIFont.typewriterFont(14.0)
        self.textColor = UIColor.blackColor()

        self.setNeedsDisplay()
    }

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRectForBounds(bounds)
        rect.origin.x -= 10
        return rect
    }

    private func rectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset( bounds , 30 , 10 );
    }

    func textDidBeginEditing(notification: NSNotification) {
        if let textField = notification.object as? UITextField {
            if textField == self {
                UIView.animateWithDuration(0.2, animations: {
                    textField.backgroundColor = UIColor.whiteColor()
                })
            }
        }
    }

    func textDidEndEditing(notification: NSNotification) {
        if let textField = notification.object as? UITextField {
            if textField == self {
                UIView.animateWithDuration(0.2, animations: {
                    textField.backgroundColor = UIColor.greyE5()
                })
            }
        }
    }
}
