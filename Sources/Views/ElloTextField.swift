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

    var imageRepresentation: UIImage {
        return SVGKImage(named: self.rawValue).UIImage
    }
}

public class ElloTextField: UITextField {

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init(coder: NSCoder) {
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
        self.rightViewMode = .Always
        self.rightView = state.map { UIImageView(image: $0.imageRepresentation) }
    }

    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override public func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRectForBounds(bounds)
        rect.origin.x -= 10
        return rect
    }

    override public func rightViewRectForBounds(bounds: CGRect) -> CGRect {
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
