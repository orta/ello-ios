//
//  ElloTextFieldView.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class ElloTextFieldView: UIView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak public var textField: ElloTextField!

    var textFieldDidChange: (String -> ())? {
        didSet {
            textField.addTarget(self, action: "valueChanged", forControlEvents: .EditingChanged)
        }
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
}
