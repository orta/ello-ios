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

    func sharedSetup() {
        self.backgroundColor = UIColor.elloTextFieldGray()
        self.font = UIFont.typewriterFont(14.0)
        self.textColor = UIColor.blackColor()
    }

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    private func rectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset( bounds , 30 , 10 );
    }
}
