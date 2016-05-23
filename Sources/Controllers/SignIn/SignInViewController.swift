//
//  SignIn.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Alamofire
import OnePasswordExtension

public class SignInViewController: BaseElloViewController, HasAppController {

    @IBOutlet weak public var enterButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak public var scrollView: UIScrollView!
    @IBOutlet weak public var emailTextField: ElloTextField!
    @IBOutlet weak public var passwordTextField: ElloTextField!
    @IBOutlet weak public var enterButton: ElloButton!
    @IBOutlet weak public var forgotPasswordButton: ElloTextButton!
    @IBOutlet weak public var joinButton: ElloTextButton!
    weak public var errorLabel: ElloErrorLabel!
    weak public var elloLogo: ElloLogoView!
    @IBOutlet weak public var onePasswordButton: UIButton!

    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    var parentAppController: AppViewController?

    required public init() {
        super.init(nibName: "SignInViewController", bundle: NSBundle(forClass: SignInViewController.self))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupTextFields()
        setupNotificationObservers()

        let onePasswordAvailable = OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
        passwordTextField.hasOnePassword = onePasswordAvailable
        onePasswordButton.hidden = !onePasswordAvailable
    }

    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotificationObservers()
    }

    // MARK: - Private

    private func setupStyles() {
        scrollView.contentSize = view.bounds.size
        modalTransitionStyle = .CrossDissolve
        scrollView.backgroundColor = .whiteColor()
        view.backgroundColor = .whiteColor()
        view.setNeedsDisplay()
    }

    private func setupTextFields() {
        errorLabel.text = ""
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    private func setupNotificationObservers() {
        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: keyboardWillChangeFrame)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: keyboardWillChangeFrame)
    }

    private func removeNotificationObservers() {
        keyboardWillShowObserver?.removeObserver()
        keyboardWillShowObserver = nil

        keyboardWillHideObserver?.removeObserver()
        keyboardWillHideObserver = nil
    }

    private func keyboardWillChangeFrame(keyboard: Keyboard) {
        let bottomInset = keyboard.keyboardBottomInset(inView: scrollView)
        scrollView.contentInset.bottom = bottomInset
        scrollView.scrollIndicatorInsets.bottom = bottomInset
        scrollView.contentOffset = CGPoint(x: 0, y: keyboard.active ? keyboard.bottomInset - 100 : 0)
    }

    private var trimmedEmail: String { return emailTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) ?? "" }
    private var password: String { return passwordTextField.text ?? "" }

    private func hasValidCredentials() -> Bool {
        return trimmedEmail.isValidEmail() && password.isValidPassword()
    }

    private func invalidCredentialsReason() -> String {
        if !trimmedEmail.isValidEmail() {
            return InterfaceString.SignIn.EmailInvalid
        }
        else if !password.isValidPassword() {
            return InterfaceString.SignIn.PasswordInvalid
        }
        else {
            return InterfaceString.SignIn.CredentialsInvalid
        }
    }

    private func enableInputs() {
        elloLogo.stopAnimatingLogo()
        emailTextField.enabled = true
        passwordTextField.enabled = true
        view.userInteractionEnabled = true
    }

    private func disableInputs() {
        elloLogo.animateLogo()
        emailTextField.enabled = false
        passwordTextField.enabled = false
        view.userInteractionEnabled = false
    }

    func submit() {
        Tracker.sharedTracker.tappedSignIn()

        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        if hasValidCredentials() {
            Tracker.sharedTracker.signInValid()
            hideErrorLabel()
            disableInputs()

            let email = trimmedEmail
            let password = self.password
            let authService = CredentialsAuthService()
            authService.authenticate(email: email,
                password: password,
                success: {

                    Tracker.sharedTracker.signInSuccessful()
                    self.loadCurrentUser()
                },
                failure: { (error, statusCode) in
                    Tracker.sharedTracker.signInFailed()
                    self.enableInputs()
                    let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
                    self.showErrorLabel(errorTitle)
            })
        }
        else {
            Tracker.sharedTracker.signInInvalid()
            let errorTitle = invalidCredentialsReason()
            showErrorLabel(errorTitle)
        }
    }

    private func loadCurrentUser() {
        parentAppController?.loadCurrentUser() { error in
            self.enableInputs()
            let errorTitle = error.elloErrorMessage ?? InterfaceString.SignIn.LoadUserError
            self.showErrorLabel(errorTitle)
        }
    }

    private func showErrorLabel(errorText: String) {
        errorLabel.setLabelText(errorText)

        UIView.animateWithDuration(0.25) {
            self.errorLabel.alpha = 1.0
            self.enterButtonTopConstraint.constant = 35.0 + self.errorLabel.height()
            self.view.layoutIfNeeded()
        }
    }

    func showErrorFromJoin(errorText: String) {
        errorLabel.setLabelText(errorText)
        self.errorLabel.alpha = 1.0
        self.enterButtonTopConstraint.constant = 35.0 + self.errorLabel.height()
    }

    private func hideErrorLabel() {
        if errorLabel.alpha != 0.0 {
            UIView.animateWithDuration(0.25) {
                self.errorLabel.alpha = 0.0
                self.enterButtonTopConstraint.constant = 30.0
                self.view.layoutIfNeeded()
            }
        }
    }

// MARK: - IBActions

    @IBAction public func enterTapped(sender: ElloButton) {
        submit()
    }

    @IBAction func forgotPasswordTapped(sender: ElloTextButton) {
        Tracker.sharedTracker.tappedForgotPassword()

        let browser = ElloWebBrowserViewController()
        let nav = ElloWebBrowserViewController.navigationControllerWithBrowser(browser)
        let url = "\(ElloURI.baseURL)/forgot-my-password"
        Tracker.sharedTracker.webViewAppeared(url)
        browser.loadURLString(url)
        browser.tintColor = UIColor.greyA()

        browser.showsURLInNavigationBar = false
        browser.showsPageTitleInNavigationBar = false
        browser.title = InterfaceString.SignIn.ForgotPassword
        browser.toolbarHidden = true

        presentViewController(nav, animated: true, completion: nil)
    }

    @IBAction func joinTapped(sender: ElloTextButton) {
        Tracker.sharedTracker.tappedJoinFromSignIn()
        let joinController = JoinViewController()
        parentAppController?.swapViewController(joinController)
    }

    @IBAction func findLoginFrom1Password(sender: UIButton) {
        OnePasswordExtension.sharedExtension().findLoginForURLString(ElloURI.baseURL, forViewController: self, sender: sender) {
            (loginDict, error) in


            if loginDict == nil {
                if let loginCode = error?.code, error = error where loginCode != Int(AppExtensionErrorCodeCancelledByUser) {
                    print("Error invoking 1Password App Extension for find login: \(error)")
                }
                return
            }

            if let email = loginDict?[AppExtensionUsernameKey] as? String {
                self.emailTextField.text = email
            }
            else {
                self.emailTextField.becomeFirstResponder()
            }

            if let password = loginDict?[AppExtensionPasswordKey] as? String {
                self.passwordTextField.text = password
            }

            if self.trimmedEmail.characters.count > 0 && self.password.characters.count > 0 {
                self.submit()
            }
        }
    }
}

extension SignInViewController: UITextFieldDelegate {

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            Tracker.sharedTracker.enteredEmail()
            passwordTextField.becomeFirstResponder()
            return true
        case passwordTextField:
            Tracker.sharedTracker.enteredPassword()
            submit()
            return false
        default:
            return true
        }
    }
}
