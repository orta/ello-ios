//
//  ForgotPasswordViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 12/4/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public class ForgotPasswordViewController: BaseElloViewController, UITextFieldDelegate {

    @IBOutlet weak public var scrollView: UIScrollView!
    @IBOutlet weak public var emailTextField: ElloTextField!
    @IBOutlet weak public var resetPasswordButton: ElloButton!
    @IBOutlet weak public var signInButton: ElloTextButton!

    private var keyboardWillHideObserver: NotificationObserver?
    private var keyboardWillShowObserver: NotificationObserver?

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupTextFields()
        setupNotificationObservers()
    }

    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotificationObservers()
    }

    public class func instantiateFromStoryboard() -> ForgotPasswordViewController {
        return UIStoryboard.storyboardWithId(.ForgotPassword) as! ForgotPasswordViewController
    }

    // MARK: - Private

    private func setupStyles() {
        scrollView.contentSize = view.bounds.size
        modalTransitionStyle = .CrossDissolve
        scrollView.backgroundColor = UIColor.grey3()
        view.backgroundColor = UIColor.grey3()
        view.setNeedsDisplay()
    }

    private func setupTextFields() {
        emailTextField.delegate = self
        resetPasswordButton.enabled = false
    }

    private func setupNotificationObservers() {
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: keyboardWillChangeFrame)
        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: keyboardWillChangeFrame)
    }

    private func removeNotificationObservers() {
        keyboardWillHideObserver?.removeObserver()
        keyboardWillShowObserver?.removeObserver()
    }

    // MARK: Keyboard Event Notifications

    private func keyboardWillChangeFrame(keyboard: Keyboard) {
        scrollView.contentInset.bottom = keyboard.topEdge
        scrollView.scrollIndicatorInsets.bottom = keyboard.topEdge
    }

    private func isValid(email:String) -> Bool {
        return email.isValidEmail()
    }

    // MARK: - UITextFieldDelegate

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            return false
        default:
            return true
        }
    }

    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        let proposedString = NSMutableString(string: textField.text)
        proposedString.replaceCharactersInRange(range, withString: string)

        switch textField {
        case emailTextField:
            resetPasswordButton.enabled = isValid(proposedString as String)
            return true
        default:
            return true
        }
    }

    // MARK: - IBActions

    @IBAction func resetPasswordTapped(sender: ElloButton) {
        if isValid(emailTextField.text) {
        }
        else {
        }
    }

    @IBAction func signInTapped(sender: ElloTextButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
