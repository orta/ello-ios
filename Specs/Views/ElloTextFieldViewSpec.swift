//
//  ElloTextFieldViewSpec.swift
//  Ello
//
//  Created by Colin Gray on 4/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class ElloTextFieldViewSpec: QuickSpec {
    override func spec() {
        describe("Styling helpers") {
            it("should style a text field as an email input") {
                let usernameView = ElloTextFieldView(frame: CGRectZero)
                ElloTextFieldView.styleAsUsername(usernameView)

                expect(usernameView.label.text) == "Username"
                expect(usernameView.textField.text) == ""
                expect(usernameView.textField.autocapitalizationType) == UITextAutocapitalizationType.None
                expect(usernameView.textField.autocorrectionType) == UITextAutocorrectionType.No
                expect(usernameView.textField.spellCheckingType) == UITextSpellCheckingType.No
                expect(usernameView.textField.keyboardAppearance) == UIKeyboardAppearance.Dark
                expect(usernameView.textField.enablesReturnKeyAutomatically) == true
                expect(usernameView.textField.returnKeyType) == UIReturnKeyType.Next
                expect(usernameView.textField.keyboardType) == UIKeyboardType.ASCIICapable
            }

            it("should style a text field as an username input") {
                let emailView = ElloTextFieldView(frame: CGRectZero)
                ElloTextFieldView.styleAsEmail(emailView)

                expect(emailView.label.text) == "Email"
                expect(emailView.textField.text) == ""
                expect(emailView.textField.autocapitalizationType) == UITextAutocapitalizationType.None
                expect(emailView.textField.autocorrectionType) == UITextAutocorrectionType.No
                expect(emailView.textField.spellCheckingType) == UITextSpellCheckingType.No
                expect(emailView.textField.keyboardAppearance) == UIKeyboardAppearance.Dark
                expect(emailView.textField.enablesReturnKeyAutomatically) == true
                expect(emailView.textField.returnKeyType) == UIReturnKeyType.Next
                expect(emailView.textField.keyboardType) == UIKeyboardType.EmailAddress
            }

            it("should style a text field as an password input") {
                let passwordView = ElloTextFieldView(frame: CGRectZero)
                ElloTextFieldView.styleAsPassword(passwordView)

                expect(passwordView.label.text) == "Password"
                expect(passwordView.textField.autocapitalizationType) == UITextAutocapitalizationType.None
                expect(passwordView.textField.autocorrectionType) == UITextAutocorrectionType.No
                expect(passwordView.textField.spellCheckingType) == UITextSpellCheckingType.No
                expect(passwordView.textField.keyboardAppearance) == UIKeyboardAppearance.Dark
                expect(passwordView.textField.enablesReturnKeyAutomatically) == true
                expect(passwordView.textField.returnKeyType) == UIReturnKeyType.Default
                expect(passwordView.textField.keyboardType) == UIKeyboardType.Default
                expect(passwordView.textField.secureTextEntry) == true
            }

        }
    }
}
