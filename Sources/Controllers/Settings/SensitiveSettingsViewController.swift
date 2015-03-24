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
    @IBOutlet weak var usernameField: ElloTextField!
    @IBOutlet weak var emailField: ElloTextField!
    @IBOutlet weak var passwordField: ElloTextField!
    @IBOutlet weak var currentPasswordField: ElloTextField!

    var currentUser: User?
    var delegate: SensitiveSettingsDelegate?

    var isUpdatable: Bool {
        return currentUser?.username != usernameField.text
            || currentUser?.email != emailField.text
            || !passwordField.text.isEmpty
    }

    var height: CGFloat {
        return isUpdatable ? SensitiveSettingsOpenHeight : SensitiveSettingsClosedHeight
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameField.text = currentUser?.username
        emailField.text = currentUser?.email
        setupNotifications()
    }

    private func setupNotifications() {
        usernameField.addTarget(self, action: "valueChanged", forControlEvents: .EditingChanged)
        emailField.addTarget(self, action: "valueChanged", forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: "valueChanged", forControlEvents: .EditingChanged)
    }

    func valueChanged() {
        delegate?.sensitiveSettingsDidUpdate()
    }
}

extension SensitiveSettingsViewController {
    class func instantiateFromStoryboard() -> SensitiveSettingsViewController {
        return UIStoryboard(name: "Settings", bundle: NSBundle(forClass: AppDelegate.self)).instantiateViewControllerWithIdentifier("SensitiveSettingsViewController") as SensitiveSettingsViewController
    }
}
