//
//  CredentialSettingsViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

private let CredentialSettingsSubmitViewHeight: CGFloat = 128

public protocol CredentialSettingsDelegate {
    func credentialSettingsDidUpdate()
}

private enum CredentialSettingsRow: Int {
    case Username
    case Email
    case Password
    case Submit
    case Unknown
}

public class CredentialSettingsViewController: UITableViewController {
    @IBOutlet weak public var usernameView: ElloTextFieldView!
    @IBOutlet weak public var emailView: ElloTextFieldView!
    @IBOutlet weak public var passwordView: ElloTextFieldView!
    @IBOutlet weak public var currentPasswordField: ElloTextField!
    @IBOutlet weak public var errorLabel: ElloErrorLabel!
    @IBOutlet weak public var saveButton: ElloButton!

    public var currentUser: User?
    public var delegate: CredentialSettingsDelegate?
    var validationCancel: Functional.BasicBlock?

    public var isUpdatable: Bool {
        return currentUser?.username != usernameView.textField.text
            || currentUser?.profile?.email != emailView.textField.text
            || !passwordView.textField.text.isEmpty
    }

    public var height: CGFloat {
        let cellHeights = usernameView.height + emailView.height + passwordView.height
        return cellHeights + (isUpdatable ? submitViewHeight : 0)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        usernameView.label.setLabelText(NSLocalizedString("Username", comment: "username key"))
        usernameView.textField.text = currentUser?.username
        usernameView.textFieldDidChange = { text in
            self.valueChanged()
            self.usernameView.setState(.Loading)
            self.validationCancel?()
            self.usernameView.setErrorMessage("");
            self.usernameView.setMessage("");
            self.updateView()

            self.validationCancel = Functional.cancelableDelay(0.5) {
                if text.isEmpty {
                    self.usernameView.setState(.Error)
                } else if text == self.currentUser?.username {
                    self.usernameView.setState(.None)
                } else {
                    AvailabilityService().usernameAvailability(text, success: { availability in
                        if text != self.usernameView.textField.text { return }
                        let state: ValidationState = availability.isUsernameAvailable ? .OK : .Error

                        if !availability.isUsernameAvailable {
                            let msg = NSLocalizedString("Username already exists.\nPlease try a new one.", comment: "username exists error message")
                            self.usernameView.setErrorMessage(msg)
                            if !availability.usernameSuggestions.isEmpty {
                                let suggestions = ", ".join(availability.usernameSuggestions)
                                let msg = String(format: NSLocalizedString("Here are some available usernames -\n%@", comment: "username suggestions message"), suggestions)
                                self.usernameView.setMessage(msg);
                            }
                        }
                        self.usernameView.setState(state)
                        self.updateView()
                    }, failure: { _, _ in
                        self.usernameView.setState(.None)
                        self.updateView()
                    })
                }
                self.updateView()
            }
        }

        emailView.label.setLabelText(NSLocalizedString("Email", comment: "email key"))
        emailView.textField.text = currentUser?.profile?.email
        emailView.textFieldDidChange = { text in
            self.valueChanged()
            self.emailView.setState(.Loading)
            self.validationCancel?()
            self.emailView.setErrorMessage("");
            self.updateView()

            self.validationCancel = Functional.cancelableDelay(0.5) {
                if text.isEmpty {
                    self.emailView.setState(.Error)
                } else if text == self.currentUser?.profile?.email {
                    self.emailView.setState(.None)
                } else if text.isValidEmail() {
                    AvailabilityService().emailAvailability(text, success: { availability in
                        if text != self.emailView.textField.text { return }
                        let state: ValidationState = availability.isEmailAvailable ? .OK : .Error

                        if !availability.isEmailAvailable {
                            let msg = NSLocalizedString("That email is invalid.\nPlease try again.", comment: "invalid email message")
                            self.emailView.setErrorMessage(msg)
                        }
                        self.emailView.setState(state)
                        self.updateView()
                    }, failure: { _, _ in
                        self.emailView.setState(.None)
                        self.updateView()
                    })
                } else {
                    self.emailView.setState(.Error)
                    let msg = NSLocalizedString("That email is invalid.\nPlease try again.", comment: "invalid email message")
                    self.emailView.setErrorMessage(msg)
                }
                self.updateView()
            }
        }

        passwordView.label.setLabelText(NSLocalizedString("Password", comment: "password key"))
        passwordView.textField.secureTextEntry = true
        passwordView.textFieldDidChange = { text in
            self.valueChanged()
            self.passwordView.setErrorMessage("")

            if text.isEmpty {
                self.passwordView.setState(.None)
            } else if text.isValidPassword() {
                self.passwordView.setState(.OK)
            } else {
                self.passwordView.setState(.Error)
                let msg = NSLocalizedString("Password must be at least 8\ncharacters long.", comment: "password length error message")
                self.passwordView.setErrorMessage(msg)
            }
            self.updateView()
        }

        currentPasswordField.addTarget(self, action: "passwordChanged", forControlEvents: .EditingChanged)
    }

    public func valueChanged() {
        delegate?.credentialSettingsDidUpdate()
    }

    private func updateView() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        valueChanged()
    }

    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch CredentialSettingsRow(rawValue: indexPath.row) ?? .Unknown {
        case .Username: return usernameView.height
        case .Email: return emailView.height
        case .Password: return passwordView.height
        case .Submit: return submitViewHeight
        case .Unknown: return 0
        }
    }

    private var submitViewHeight: CGFloat {
        let height = CredentialSettingsSubmitViewHeight
        return height + (errorLabel.text != "" ? errorLabel.frame.height + 8 : 0)
    }

    public func passwordChanged() {
        saveButton.enabled = currentPasswordField.text.isValidPassword()
    }

    @IBAction func saveButtonTapped() {
        var content: [String: AnyObject] = [
            "username": usernameView.textField.text,
            "email": emailView.textField.text,
            "current_password": currentPasswordField.text
        ]

        if !passwordView.textField.text.isEmpty {
            content["password"] = passwordView.textField.text
            content["password_confirmation"] = passwordView.textField.text
        }

        if let nav = self.navigationController as? ElloNavigationController {
            ProfileService().updateUserProfile(content, success: {
                nav.setProfileData($0, responseConfig: $1)
                self.resetViews()
            }) { error, _ in
                self.currentPasswordField.text = ""
                self.passwordView.textField.text = ""

                if let err = error.userInfo?[NSLocalizedFailureReasonErrorKey] as? ElloNetworkError {
                    self.handleError(err)
                }
            }
        }
    }

    private func resetViews() {
        currentPasswordField.text = ""
        passwordView.textField.text = ""
        errorLabel.setLabelText("")
        usernameView.clearState()
        emailView.clearState()
        passwordView.clearState()
        updateView()
    }

    private func handleError(error: ElloNetworkError) {
        if let message = error.attrs?["password"] {
            passwordView.setErrorMessage(message.first ?? "")
        }

        if let message = error.attrs?["email"] {
            emailView.setErrorMessage(message.first ?? "")
        }

        if let message = error.attrs?["username"] {
            usernameView.setErrorMessage(message.first ?? "")
        }

        errorLabel.setLabelText(error.messages?.first ?? "")
        errorLabel.sizeToFit()

        updateView()
    }
}

public extension CredentialSettingsViewController {
    class func instantiateFromStoryboard() -> CredentialSettingsViewController {
        return UIStoryboard(name: "Settings", bundle: NSBundle(forClass: AppDelegate.self)).instantiateViewControllerWithIdentifier("CredentialSettingsViewController") as! CredentialSettingsViewController
    }
}
