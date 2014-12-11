//
//  RequestInviteViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class RequestInviteViewController: BaseElloViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: ElloTextField!
    @IBOutlet weak var requestInviteButton: ElloButton!
    @IBOutlet weak var signInButton: ElloTextButton!

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

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> RequestInviteViewController {
        return storyboard.controllerWithID(.RequestInvite) as RequestInviteViewController
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
        requestInviteButton.enabled = false
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
            requestInviteButton.enabled = isValid(emailTextField.text)
            return true
        default:
            return true
        }
    }

    // MARK: - IBActions

    @IBAction func requestInvitTapped(sender: ElloButton) {

        if isValid(emailTextField.text) {
//            ElloHUD.showLoadingHud()
        }
        else {
            
        }
    }

    @IBAction func signInTapped(sender: ElloTextButton) {
        let signInController = SignInViewController.instantiateFromStoryboard()
        self.presentViewController(signInController, animated:true, completion:nil)
    }
    
}
