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
    case None = ""

    var imageRepresentation: UIImage? {
        switch self {
        case .None: return .None
        default: return SVGKImage(named: self.rawValue).UIImage
        }
    }
}

public class ElloTextField: UITextField {
    var hasOnePassword = false
    var validationState = ValidationState.None {
        didSet {
            self.rightViewMode = .Always
            self.rightView = UIImageView(image: validationState.imageRepresentation)
        }
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        self.backgroundColor = UIColor.greyE5()
        self.font = UIFont.typewriterFont(14.0)
        self.textColor = UIColor.blackColor()

        self.setNeedsDisplay()
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
        if hasOnePassword {
            rect.origin.x -= 44
        }
        return rect
    }

    override public func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.rightViewRectForBounds(bounds)
        rect.origin.x -= 10
        return rect
    }

    private func rectForBounds(var bounds: CGRect) -> CGRect {
        bounds.size.width -= 15
        return CGRectInset(bounds, 15, 10)
    }

}
