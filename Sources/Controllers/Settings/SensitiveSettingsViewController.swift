//
//  SensitiveSettingsViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

private let SensitiveSettingsClosedHeight: CGFloat = 89 * 3
private let SensitiveSettingsOpenHeight: CGFloat = SensitiveSettingsClosedHeight + 128

protocol SensitiveSettingsDelegate {
    func sensitiveSettingsDidUpdate()
}

class SensitiveSettingsViewController: UITableViewController {
    @IBOutlet weak var usernameView: ElloTextFieldView!
    @IBOutlet weak var emailView: ElloTextFieldView!
    @IBOutlet weak var passwordView: ElloTextFieldView!
    @IBOutlet weak var currentPasswordField: ElloTextField!

    var currentUser: User?
    var delegate: SensitiveSettingsDelegate?
    var validationCancel: Functional.BasicBlock?

    var isUpdatable: Bool {
        return currentUser?.username != usernameView.textField.text
            || currentUser?.email != emailView.textField.text
            || !passwordView.textField.text.isEmpty
    }

    var height: CGFloat {
        return isUpdatable ? SensitiveSettingsOpenHeight : SensitiveSettingsClosedHeight
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        usernameView.label.text = "Username"
        usernameView.textField.text = currentUser?.username
        usernameView.textFieldDidChange = { text in
            self.valueChanged()
            self.usernameView.setState(.Loading)
            self.validationCancel?()

            self.validationCancel = Functional.cancelableDelay(0.5) {
                if text.isEmpty {
                    self.usernameView.setState(.Error)
                } else if text == self.currentUser?.username {
                    self.usernameView.setState(.None)
                } else {
                    println("callback")
                    AvailabilityService().usernameAvailability(text, success: { availability in
                        if text != self.usernameView.textField.text { return }
                        let state: ValidationState = availability.username ? .OK : .Error
                        self.usernameView.setState(state)
                        }, failure: { _, _ in
                            self.usernameView.setState(.None)
                    })
                }
            }
        }

        emailView.label.text = "Email"
        emailView.textField.text = currentUser?.email
        emailView.textFieldDidChange = { text in
            self.valueChanged()
            self.emailView.setState(.Loading)
            self.validationCancel?()

            self.validationCancel = Functional.cancelableDelay(0.5) {
                if text.isEmpty {
                    self.emailView.setState(.Error)
                } else if text == self.currentUser?.email {
                    self.emailView.setState(.None)
                } else if text.isValidEmail() {
                    AvailabilityService().emailAvailability(text, success: { availability in
                        if text != self.emailView.textField.text { return }
                        let state: ValidationState = availability.email ? .OK : .Error
                        self.emailView.setState(state)
                        }, failure: { _, _ in
                            self.emailView.setState(.None)
                    })
                } else {
                    self.emailView.setState(.Error)
                }
            }
        }

        passwordView.label.text = "Password"
        passwordView.textField.secureTextEntry = true
        passwordView.textFieldDidChange = { text in
            self.valueChanged()
            if text.isEmpty {
                self.passwordView.setState(.None)
            } else if text.isValidPassword() {
                self.passwordView.setState(.OK)
            } else {
                self.passwordView.setState(.Error)
            }
        }
    }

    func valueChanged() {
        delegate?.sensitiveSettingsDidUpdate()
    }
}

extension SensitiveSettingsViewController {
    class func instantiateFromStoryboard() -> SensitiveSettingsViewController {
        return UIStoryboard(name: "Settings", bundle: NSBundle(forClass: AppDelegate.self)).instantiateViewControllerWithIdentifier("SensitiveSettingsViewController") as! SensitiveSettingsViewController
    }
}
