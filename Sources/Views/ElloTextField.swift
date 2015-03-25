//
//  ElloTextField.swift
//  Ello
//
//  Created by Sean Dougherty on 11/25/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SVGKit

enum ValidationState: String {
    case Loading = "circ_normal.svg"
    case Error = "x_red.svg"
    case OK = "check_green.svg"

    var imageView: UIImageView {
        return UIImageView(image: SVGKImage(named: self.rawValue).UIImage)
    }
}

class ElloTextField: UITextField {
    private var validationState: ValidationState?

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

    func setValidationState(state: ValidationState?) {
        validationState = state
        self.rightViewMode = .Always
        self.rightView = validationState?.imageView
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

    override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.rightViewRectForBounds(bounds)
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
