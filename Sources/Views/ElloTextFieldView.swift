//
//  ElloTextFieldView.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

private let ElloTextFieldViewHeight: CGFloat = 89.0

public class ElloTextFieldView: UIView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: ElloTextField!
    @IBOutlet weak var messageLabel: UILabel!

    var textFieldDidChange: (String -> ())? {
        didSet {
            textField.addTarget(self, action: "valueChanged", forControlEvents: .EditingChanged)
        }
    }

    var height: CGFloat {
        return ElloTextFieldViewHeight + messageLabel.frame.height
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view: UIView = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        addSubview(view)
    }

    func setState(state: ValidationState?) {
        textField.setValidationState(state)
    }

    func valueChanged() {
        textFieldDidChange?(textField.text)
    }

    func setMessage(message: String) {
        messageLabel.text = message
        messageLabel.sizeToFit()
    }
}
