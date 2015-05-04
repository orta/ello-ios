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
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }

    private func removeNotificationObservers() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }

    private func keyboardWillChangeFrame(notification: NSNotification, showsKeyboard: Bool) {
        if let userInfo = notification.userInfo {
            let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)

            if shouldAdjustScrollViewForKeyboard(keyboardViewEndFrame) || !showsKeyboard {
                let keyboardHeight = showsKeyboard ? keyboardViewEndFrame.size.height : 0
                let adjustedInsets = UIEdgeInsetsMake(
                    scrollView.contentInset.top,
                    scrollView.contentInset.left,
                    keyboardHeight,
                    scrollView.contentInset.right
                )
                scrollView.contentInset = adjustedInsets
                scrollView.scrollIndicatorInsets = adjustedInsets
            }
        }
    }

    private func shouldAdjustScrollViewForKeyboard(rect:CGRect) -> Bool {
        return (rect.origin.y + rect.size.height) == view.bounds.size.height
    }

    private func isValid(email:String) -> Bool {
        return email.isValidEmail()
    }

    // MARK: Keyboard Event Notifications

    func keyboardWillShow(notification: NSNotification) {
        keyboardWillChangeFrame(notification, showsKeyboard: true)
    }

    func keyboardWillHide(notification: NSNotification) {
        keyboardWillChangeFrame(notification, showsKeyboard: false)
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

