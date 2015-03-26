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
            if text.isEmpty {
                return .Error
            } else if text == self.currentUser?.username {
                return .None
            } else {
                return .Loading
            }
        }

        emailView.label.text = "Email"
        emailView.textField.text = currentUser?.email
        emailView.textFieldDidChange = { text in
            self.valueChanged()
            if text.isEmpty {
                return .Error
            } else if text == self.currentUser?.username {
                return .None
            } else {
                if text.rangeOfString("^.+@.+\\.[A-Za-z]{2}[A-Za-z]*$", options: .RegularExpressionSearch) != nil {
                    // send to ello
                    return .None
                } else {
                    return .Error
                }
            }
        }

        passwordView.label.text = "Password"
        passwordView.textField.secureTextEntry = true
        passwordView.textFieldDidChange = { text in
            self.valueChanged()
            if text.isEmpty {
                return .None
            } else if count(text) < 8 {
                return .Error
            } else {
                return .OK
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
