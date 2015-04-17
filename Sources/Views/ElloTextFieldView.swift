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
    @IBOutlet public weak var label: ElloToggleLabel!
    @IBOutlet public weak var textField: ElloTextField!
    @IBOutlet public weak var errorLabel: ElloErrorLabel!
    @IBOutlet public weak var messageLabel: ElloLabel!

    var textFieldDidChange: (String -> ())? {
        didSet {
            textField.addTarget(self, action: "valueChanged", forControlEvents: .EditingChanged)
        }
    }

    var height: CGFloat {
        var height = ElloTextFieldViewHeight
        height += (errorLabel.text?.isEmpty ?? true) ? 0 : errorLabel.frame.height + 8
        height += (messageLabel.text?.isEmpty ?? true) ? 0 : messageLabel.frame.height + 20
        return height
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        let view: UIView = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        addSubview(view)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view: UIView = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        addSubview(view)
    }

    func setState(state: ValidationState) {
        textField.setValidationState(state)
    }

    func valueChanged() {
        textFieldDidChange?(textField.text)
    }

    func setErrorMessage(message: String) {
        errorLabel.setLabelText(message)
        errorLabel.sizeToFit()
    }

    func setMessage(message: String) {
        messageLabel.setLabelText(message)
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.sizeToFit()
    }

    func clearState() {
        textField.setValidationState(.None)
        setErrorMessage("")
        setMessage("")
    }
}


public extension ElloTextFieldView {

    class func styleAsUsername(usernameView: ElloTextFieldView) {
        usernameView.label.setLabelText(NSLocalizedString("Username", comment: "username key"))
        usernameView.textField.text = ""
        usernameView.textField.autocapitalizationType = .None
        usernameView.textField.autocorrectionType = .No
        usernameView.textField.spellCheckingType = .No
        usernameView.textField.keyboardAppearance = .Dark
        usernameView.textField.enablesReturnKeyAutomatically = true
        usernameView.textField.returnKeyType = .Next
        usernameView.textField.keyboardType = .ASCIICapable
    }

    class func styleAsEmail(emailView: ElloTextFieldView) {
        emailView.label.setLabelText(NSLocalizedString("Email", comment: "email key"))
        emailView.textField.text = ""
        emailView.textField.autocapitalizationType = .None
        emailView.textField.autocorrectionType = .No
        emailView.textField.spellCheckingType = .No
        emailView.textField.keyboardAppearance = .Dark
        emailView.textField.enablesReturnKeyAutomatically = true
        emailView.textField.returnKeyType = .Next
        emailView.textField.keyboardType = .EmailAddress
    }

    class func styleAsPassword(passwordView: ElloTextFieldView) {
        passwordView.label.setLabelText(NSLocalizedString("Password", comment: "password key"))
        passwordView.textField.autocapitalizationType = .None
        passwordView.textField.autocorrectionType = .No
        passwordView.textField.spellCheckingType = .No
        passwordView.textField.keyboardAppearance = .Dark
        passwordView.textField.enablesReturnKeyAutomatically = true
        passwordView.textField.returnKeyType = .Default
        passwordView.textField.keyboardType = .Default
        passwordView.textField.secureTextEntry = true
    }

}
