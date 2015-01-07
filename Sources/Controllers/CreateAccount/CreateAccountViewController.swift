//
//  CreateAccountViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class CreateAccountViewController: BaseElloViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: ElloTextField!
    @IBOutlet weak var usernameTextField: ElloTextField!
    @IBOutlet weak var passwordTextField: ElloTextField!
    @IBOutlet weak var aboutButton: ElloTextButton!
    @IBOutlet weak var loginButton: ElloTextButton!
    @IBOutlet weak var createAccountButton: ElloButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupTextFields()
        setupNotificationObservers()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotificationObservers()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> CreateAccountViewController {
        return storyboard.controllerWithID(.CreateAccount) as CreateAccountViewController
    }

    // MARK: - Private

    private func setupStyles() {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        scrollView.contentSize = view.bounds.size
        modalTransitionStyle = .CrossDissolve
        scrollView.backgroundColor = UIColor.elloDarkGray()
        view.backgroundColor = UIColor.elloDarkGray()
        view.setNeedsDisplay()
    }

    private func setupTextFields() {
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        createAccountButton.enabled = false
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
            let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
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

    private func isValid(email:String, _ username:String, _ password:String) -> Bool {
        // TODO: add fancy server side validation/suggestion
        return email.isValidEmail() && password.isValidPassword()
    }

    // MARK: Keyboard Event Notifications

    func keyboardWillShow(notification: NSNotification) {
        keyboardWillChangeFrame(notification, showsKeyboard: true)
    }

    func keyboardWillHide(notification: NSNotification) {
        keyboardWillChangeFrame(notification, showsKeyboard: false)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            return false
        default:
            return true
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        let proposedString = NSMutableString(string: textField.text)
        proposedString.replaceCharactersInRange(range, withString: string)

        switch textField {
        case emailTextField:
            createAccountButton.enabled = isValid(emailTextField.text, usernameTextField.text, passwordTextField.text)
            return true
        default:
            return true
        }
    }

    // MARK: - IBActions

    @IBAction func createAccountTapped(sender: ElloButton) {
        println("create account tapped")
        if isValid(emailTextField.text, usernameTextField.text, passwordTextField.text) {
//            ElloHUD.showLoadingHud()
        }
        else {
            
        }
    }

    @IBAction func loginTapped(sender: ElloTextButton) {
        println("login tapped")
        let signInController = SignInViewController.instantiateFromStoryboard()
        self.presentViewController(signInController, animated:true, completion:nil)
    }
    
    @IBAction func aboutTapped(sender: ElloTextButton) {
        //TODO: show about screen
        println("about tapped")
    }
    
}
