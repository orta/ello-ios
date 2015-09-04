//
//  JoinViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public class JoinViewController: BaseElloViewController, HasAppController {

    @IBOutlet weak public var enterButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak public var passwordFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak public var containerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak public var scrollView: UIScrollView!
    @IBOutlet weak public var elloLogo: ElloLogoView!
    @IBOutlet weak public var emailField: ElloTextField!
    @IBOutlet weak public var usernameField: ElloTextField!
    @IBOutlet weak public var passwordField: ElloTextField!
    @IBOutlet weak public var loginButton: ElloTextButton!
    @IBOutlet weak public var joinButton: ElloButton!
    @IBOutlet weak public var termsButton: ElloTextButton!
    @IBOutlet weak public var errorLabel: ElloErrorLabel!
    @IBOutlet weak public var messageLabel: ElloErrorLabel!

    private var keyboardWillShowObserver: NotificationObserver?
    private var keyboardWillHideObserver: NotificationObserver?

    weak var parentAppController: AppViewController?

    required public init() {
        super.init(nibName: "JoinViewController", bundle: nil)
        modalTransitionStyle = .CrossDissolve
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupViews()
        termsButton.setAttributedTitle(ElloAttributedString.style("By Clicking Create Account you are agreeing to our ") + NSAttributedString(string: "Terms", attributes: ElloAttributedString.linkAttrs()), forState: .Normal)
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addNotificationObservers()
    }

    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotificationObservers()
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        containerHeightConstraint.constant = view.frame.height
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let margin = CGFloat(10)
        let termsBottom = termsButton.frame.maxY + margin
        scrollView.contentSize = view.bounds.withHeight(max(termsBottom, view.frame.size.height)).size
    }

    // MARK: Private

    private func setupStyles() {
        scrollView.backgroundColor = .whiteColor()
        view.backgroundColor = .whiteColor()
    }

    private func setupViews() {
        ElloTextFieldView.styleAsUsernameField(usernameField)
        usernameField.delegate = self
        usernameField.addTarget(self, action: Selector("usernameChanged:"), forControlEvents: .EditingChanged)

        ElloTextFieldView.styleAsEmailField(emailField)
        emailField.delegate = self
        emailField.addTarget(self, action: Selector("emailChanged:"), forControlEvents: .EditingChanged)

        ElloTextFieldView.styleAsPasswordField(passwordField)
        passwordField.returnKeyType = .Join
        passwordField.delegate = self
        passwordField.addTarget(self, action: Selector("passwordChanged:"), forControlEvents: .EditingChanged)
    }

    private func addNotificationObservers() {
        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: keyboardWillChangeFrame)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: keyboardWillChangeFrame)
    }

    private func removeNotificationObservers() {
        keyboardWillShowObserver?.removeObserver()
        keyboardWillHideObserver?.removeObserver()
    }

    private func showMessageLabel(messageText:String) {
        messageLabel.setLabelText(messageText)

        animate {
            self.messageLabel.alpha = 1.0
            self.passwordFieldTopConstraint.constant = 18 + self.messageLabel.height()
            self.view.layoutIfNeeded()
        }
    }

    private func hideMessageLabel() {
        if messageLabel.alpha != 0.0 {
            animate {
                self.messageLabel.alpha = 0.0
                self.passwordFieldTopConstraint.constant = 9
                self.view.layoutIfNeeded()
            }
        }
    }

    private func showErrorLabel(errorText:String) {
        errorLabel.setLabelText(errorText)

        animate {
            self.errorLabel.alpha = 1.0
            self.enterButtonTopConstraint.constant = 18 + self.errorLabel.height()
            self.view.layoutIfNeeded()
        }
    }

    private func hideErrorLabel() {
        if errorLabel.alpha != 0.0 {
            animate {
                self.errorLabel.alpha = 0.0
                self.enterButtonTopConstraint.constant = 9
                self.view.layoutIfNeeded()
            }
        }
    }

    private func join() {
        Tracker.sharedTracker.tappedJoin()

        if allFieldsValid() {
            Tracker.sharedTracker.joinValid()

            self.elloLogo.animateLogo()
            self.view.userInteractionEnabled = false

            emailField.resignFirstResponder()
            usernameField.resignFirstResponder()
            passwordField.resignFirstResponder()

            let service = UserService()
            let email = emailField.text
            let username = usernameField.text
            let password = passwordField.text
            service.join(email: email, username: username, password: password, success: { user in
                let authService = AuthService()
                authService.authenticate(email: email,
                    password: password,
                    success: {
                        Tracker.sharedTracker.joinSuccessful()
                        self.showOnboardingScreen(user)
                    },
                    failure: { _, _ in
                        Tracker.sharedTracker.joinFailed()
                        self.view.userInteractionEnabled = true
                        self.showSignInScreen(email, password)
                    })
            },
            failure: { error, _ in
                let errorTitle = error.elloErrorMessage ?? NSLocalizedString("Unknown error", comment: "Unknown error message")
                self.showErrorLabel(errorTitle)
                self.view.userInteractionEnabled = true
                self.elloLogo.stopAnimatingLogo()

                self.hideErrorLabel()
                self.validateEmail(self.emailField.text)
                self.usernameAvailability(self.usernameField.text)
            })
        }
        else {
            Tracker.sharedTracker.joinInvalid()
        }
    }

    private func showOnboardingScreen(user: User) {
        parentAppController?.showOnboardingScreen(user)
    }

    private func showSignInScreen(email: String, _ password: String) {
        let signInController = SignInViewController()
        let view = signInController.view
        signInController.emailTextField.text = email
        signInController.passwordTextField.text = password
        signInController.enterButton.enabled = true

        parentAppController?.swapViewController(signInController)
    }

    private func showSignInScreen() {
        let signInController = SignInViewController()
        parentAppController?.swapViewController(signInController)
    }

    private func showTerms() {
        let nav = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
        let browser = nav.rootWebBrowser()
        let url = "\(ElloURI.baseURL)/wtf/post/terms-of-use"
        Tracker.sharedTracker.webViewAppeared(url)
        browser.loadURLString(url)
        browser.tintColor = UIColor.greyA()
        browser.showsURLInNavigationBar = false
        browser.showsPageTitleInNavigationBar = false
        browser.title = NSLocalizedString("Terms and Conditions", comment: "terms and conditions title")

        presentViewController(nav, animated: true, completion: nil)
    }

}


// MARK: Keyboard Events
extension JoinViewController {

    private func keyboardWillChangeFrame(keyboard: Keyboard) {
        let bottomInset = keyboard.keyboardBottomInset(inView: scrollView)
        scrollView.contentInset.bottom = bottomInset
        scrollView.scrollIndicatorInsets.bottom = bottomInset
    }

}


// MARK: UITextFieldDelegate
extension JoinViewController: UITextFieldDelegate {

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            Tracker.sharedTracker.enteredEmail()
            usernameField.becomeFirstResponder()
        case usernameField:
        Tracker.sharedTracker.enteredUsername()
            passwordField.becomeFirstResponder()
        case passwordField:
            Tracker.sharedTracker.enteredPassword()
            join()
        default:
            return false
        }
        return true
    }

}


// MARK: IBActions
extension JoinViewController {

    @IBAction func joinTapped(sender: ElloButton) {
        join()
    }

    @IBAction func termsTapped(sender: ElloButton) {
        Tracker.sharedTracker.tappedTsAndCs()
        showTerms()
    }

    @IBAction func loginTapped(sender: ElloTextButton) {
        Tracker.sharedTracker.tappedSignInFromJoin()
        showSignInScreen()
    }

}


// MARK: Text field validation
extension JoinViewController {

    private func allFieldsValid() -> Bool {
        return validateEmail(emailField.text) && validateUsername(usernameField.text) && validatePassword(passwordField.text)
    }

    private func extraHeight() -> CGFloat {
        let spacing = CGRectGetMaxY(termsButton.frame) - view.bounds.height + 10
        return spacing > 0 ? spacing : 0
    }

    public func revalidateAndResizeViews() {
        scrollView.layoutIfNeeded()
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height + extraHeight())
    }

    func emailChanged(field: UITextField) {
    }

    func usernameChanged(field: UITextField) {
    }

    func passwordChanged(field: UITextField) {
    }

    private func emailAvailability(text: String) {
        AvailabilityService().emailAvailability(text, success: { availability in
            if text != self.emailField.text { return }

            if !availability.isEmailAvailable {
                let msg = NSLocalizedString("That email is invalid.\nPlease try again.", comment: "invalid email message")
                self.showErrorLabel(msg)
            }

            // self.revalidateAndResizeViews()
        }, failure: { _, _ in
            // self.revalidateAndResizeViews()
        })
    }

    private func validateEmail(text: String) -> Bool {
        if text.isEmpty {
            let msg = NSLocalizedString("Email is required.", comment: "email is required message")
            self.showErrorLabel(msg)
            // self.revalidateAndResizeViews()
            return false
        }
        else if text.isValidEmail() {
            return true
        }
        else {
            let msg = NSLocalizedString("That email is invalid.\nPlease try again.", comment: "invalid email message")
            self.showErrorLabel(msg)
            // self.revalidateAndResizeViews()
            return false
        }
    }

    private func usernameAvailability(text: String) {
        AvailabilityService().usernameAvailability(text, success: { availability in
            if text != self.usernameField.text { return }

            if !availability.isUsernameAvailable {
                let msg = NSLocalizedString("Username already exists.\nPlease try a new one.", comment: "username exists error message")
                self.showErrorLabel(msg)

                if !availability.usernameSuggestions.isEmpty {
                    let suggestions = ", ".join(availability.usernameSuggestions)
                    let msg = String(format: NSLocalizedString("Here are some available usernames -\n%@", comment: "username suggestions showmes"), suggestions)
                    self.showMessageLabel(msg)
                }
            }
            else {
                self.hideMessageLabel()
            }

            // self.revalidateAndResizeViews()
        }, failure: { _, _ in
            self.hideMessageLabel()
            // self.revalidateAndResizeViews()
        })
    }

    private func validateUsername(text: String) -> Bool {
        if text.isEmpty {
            self.hideMessageLabel()
            let msg = NSLocalizedString("Username is required.", comment: "username is required message")
            self.showErrorLabel(msg)
            // self.revalidateAndResizeViews()
            return false
        }
        else {
            return true
        }
    }

    private func validatePassword(text: String) -> Bool {
        if text.isValidPassword() {
            self.hideErrorLabel()
            // self.revalidateAndResizeViews()
            return true
        }
        else {
            let msg = NSLocalizedString("Password must be at least 8\ncharacters long.", comment: "password length error message")
            self.showErrorLabel(msg)
            // self.revalidateAndResizeViews()
            return false
        }
    }

}

