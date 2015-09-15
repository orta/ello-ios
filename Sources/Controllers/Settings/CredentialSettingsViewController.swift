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
    weak public var usernameView: ElloTextFieldView!
    weak public var emailView: ElloTextFieldView!
    weak public var passwordView: ElloTextFieldView!
    @IBOutlet weak public var currentPasswordField: ElloTextField!
    weak public var errorLabel: ElloErrorLabel!
    @IBOutlet weak public var saveButton: ElloButton!

    public var currentUser: User?
    public var delegate: CredentialSettingsDelegate?
    var validationCancel: BasicBlock?

    public var isUpdatable: Bool {
        return currentUser?.username != usernameView.textField.text
            || currentUser?.profile?.email != emailView.textField.text
            || passwordView.textField.text?.isEmpty == false
    }

    public var height: CGFloat {
        let cellHeights = usernameView.height + emailView.height + passwordView.height
        return cellHeights + (isUpdatable ? submitViewHeight : 0)
    }

    private var password: String { return passwordView.textField.text ?? "" }
    private var currentPassword: String { return currentPasswordField.text ?? "" }
    private var username: String { return usernameView.textField.text ?? "" }
    private var email: String { return emailView.textField.text ?? "" }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        ElloTextFieldView.styleAsUsername(usernameView)
        usernameView.textField.text = currentUser?.username
        usernameView.textFieldDidChange = self.usernameChanged

        ElloTextFieldView.styleAsEmail(emailView)
        emailView.textField.text = currentUser?.profile?.email
        emailView.textFieldDidChange = self.emailChanged

        ElloTextFieldView.styleAsPassword(passwordView)
        passwordView.textFieldDidChange = self.passwordChanged

        currentPasswordField.addTarget(self, action: Selector("currentPasswordChanged"), forControlEvents: .EditingChanged)

        tableView.scrollsToTop = false
    }

    private func emailChanged(text: String) {
        self.emailView.setState(.Loading)
        self.emailView.setErrorMessage("")
        self.updateView()

        self.validationCancel?()
        self.validationCancel = cancelableDelay(0.5) { [unowned self] in
            if text.isEmpty {
                self.emailView.setState(.Error)
                self.updateView()
            } else if text == self.currentUser?.profile?.email {
                self.emailView.setState(.None)
                self.updateView()
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
                self.updateView()
            }
        }
    }

    private func usernameChanged(text: String) {
        self.usernameView.setState(.Loading)
        self.usernameView.setErrorMessage("")
        self.usernameView.setMessage("")
        self.updateView()

        self.validationCancel?()
        self.validationCancel = cancelableDelay(0.5) { [unowned self] in
            if text.isEmpty {
                self.usernameView.setState(.Error)
                self.updateView()
            } else if text == self.currentUser?.username {
                self.usernameView.setState(.None)
                self.updateView()
            } else {
                AvailabilityService().usernameAvailability(text, success: { availability in
                    if text != self.usernameView.textField.text { return }
                    let state: ValidationState = availability.isUsernameAvailable ? .OK : .Error

                    if !availability.isUsernameAvailable {
                        let msg = NSLocalizedString("Username already exists.\nPlease try a new one.", comment: "username exists error message")
                        self.usernameView.setErrorMessage(msg)
                        if !availability.usernameSuggestions.isEmpty {
                            let suggestions = availability.usernameSuggestions.joinWithSeparator(", ")
                            let msg = String(format: NSLocalizedString("Here are some available usernames -\n%@", comment: "username suggestions message"), suggestions)
                            self.usernameView.setMessage(msg)
                        }
                    }
                    self.usernameView.setState(state)
                    self.updateView()
                }, failure: { _, _ in
                    self.usernameView.setState(.None)
                    self.updateView()
                })
            }
        }
    }

    private func passwordChanged(text: String) {
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

    private func updateView() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        valueChanged()
    }

    public func valueChanged() {
        delegate?.credentialSettingsDidUpdate()
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

    public func currentPasswordChanged() {
        saveButton.enabled = currentPassword.isValidPassword()
    }

    @IBAction func saveButtonTapped() {
        var content: [String: AnyObject] = [
            "username": username,
            "email": email,
            "current_password": currentPassword
        ]

        if !currentPassword.isEmpty {
            content["password"] = password
            content["password_confirmation"] = password
        }

        if let nav = self.navigationController as? ElloNavigationController {
            ProfileService().updateUserProfile(content, success: {
                nav.setProfileData($0)
                self.resetViews()
            }, failure: { error, _ in
                self.currentPasswordField.text = ""
                self.passwordView.textField.text = ""

                if let err = error.userInfo[NSLocalizedFailureReasonErrorKey] as? ElloNetworkError {
                    self.handleError(err)
                }
            })
        }
    }

    private func resetViews() {
        currentPasswordField.text = ""
        passwordView.textField.text = ""
        errorLabel.setLabelText("")
        usernameView.clearState()
        emailView.clearState()
        passwordView.clearState()
        currentPasswordChanged()
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

public extension CredentialSettingsViewController {
    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        tableView.setContentOffset(CGPointZero, animated: false)
    }
}
