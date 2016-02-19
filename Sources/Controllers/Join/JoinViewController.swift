//
//  JoinViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import OnePasswordExtension

public class JoinViewController: BaseElloViewController, HasAppController {

    @IBOutlet weak public var enterButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak public var passwordFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak public var containerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak public var scrollView: UIScrollView!
    weak public var elloLogo: ElloLogoView!
    @IBOutlet weak public var emailField: ElloTextField!
    @IBOutlet weak public var usernameField: ElloTextField!
    @IBOutlet weak public var passwordField: ElloTextField!
    @IBOutlet weak public var onePasswordButton: UIButton!
    @IBOutlet weak public var loginButton: ElloTextButton!
    @IBOutlet weak public var joinButton: ElloButton!
    @IBOutlet weak public var termsButton: ElloTextButton!
    @IBOutlet weak public var errorLabel: ElloErrorLabel!
    @IBOutlet weak public var messageLabel: ElloLabel!

    private var keyboardWillShowObserver: NotificationObserver?
    private var keyboardWillHideObserver: NotificationObserver?

    weak var parentAppController: AppViewController?

    private var email: String { return emailField.text ?? "" }
    private var username: String { return usernameField.text ?? "" }
    private var password: String { return passwordField.text ?? "" }

    required public init() {
        super.init(nibName: "JoinViewController", bundle: nil)
        modalTransitionStyle = .CrossDissolve
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupViews()

        let onePasswordAvailable = OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
        passwordField.hasOnePassword = onePasswordAvailable
        onePasswordButton.hidden = !onePasswordAvailable

        let attrs = ElloAttributedString.attrs([
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSFontAttributeName: UIFont.defaultFont(),
        ])
        let linkAttrs = ElloAttributedString.attrs(ElloAttributedString.linkAttrs(), [
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSFontAttributeName: UIFont.defaultFont(),
        ])
        termsButton.setAttributedTitle(
            NSAttributedString(string: "By Clicking Create Account you are agreeing to our ", attributes: attrs) + NSAttributedString(string: "Terms", attributes: linkAttrs), forState: .Normal)
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

        ElloTextFieldView.styleAsEmailField(emailField)
        emailField.delegate = self

        ElloTextFieldView.styleAsPasswordField(passwordField)
        passwordField.returnKeyType = .Join
        passwordField.delegate = self
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
        messageLabel.setLabelText(messageText, color: .blackColor())

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

    func join() {
        Tracker.sharedTracker.tappedJoin()

        emailField.resignFirstResponder()
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()

        if allFieldsValid(email: email, username: username, password: password) {
            hideErrorLabel()
            hideMessageLabel()

            self.elloLogo.animateLogo()
            self.view.userInteractionEnabled = false

            let joinAborted: () -> Void = {
                self.view.userInteractionEnabled = true
                self.elloLogo.stopAnimatingLogo()
            }

            self.emailAvailability(email) { successful in
                if !successful {
                    joinAborted()
                    return
                }

                self.usernameAvailability(self.username) { successful in
                    if !successful {
                        joinAborted()
                        return
                    }

                    Tracker.sharedTracker.joinValid()

                    let service = UserService()
                    service.join(email: self.email, username: self.username, password: self.password, success: { user in
                        let authService = CredentialsAuthService()
                        authService.authenticate(email: self.email,
                            password: self.password,
                            success: {
                                Tracker.sharedTracker.joinSuccessful()
                                self.showOnboardingScreen(user)
                            },
                            failure: { _, _ in
                                Tracker.sharedTracker.joinFailed()
                                self.view.userInteractionEnabled = true
                                self.showSignInScreen(self.email, self.password)
                            })
                    },
                    failure: { error, _ in
                        let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
                        self.showErrorLabel(errorTitle)
                        joinAborted()
                    })
                }
            }
        }
        else {
            if let msg = emailErrorMessage(email) {
                self.showErrorLabel(msg)
            }
            else if let msg = usernameErrorMessage(username) {
                self.showErrorLabel(msg)
            }
            else if let msg = passwordErrorMessage(password) {
                self.showErrorLabel(msg)
            }

            Tracker.sharedTracker.joinInvalid()
        }
    }

    private func showOnboardingScreen(user: User) {
        parentAppController?.showOnboardingScreen(user)
    }

    private func showSignInScreen(email: String, _ password: String) {
        let signInController = SignInViewController()
        _ = signInController.view
        signInController.showErrorFromJoin(InterfaceString.Join.SignInAfterJoinError)
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
        browser.title = InterfaceString.WebBrowser.TermsAndConditions

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
            break
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

    private func allFieldsValid(email email: String, username: String, password: String) -> Bool {
        return emailIsValid(email) && usernameIsValid(username) && passwordIsValid(password)
    }

    private func extraHeight() -> CGFloat {
        let spacing = CGRectGetMaxY(termsButton.frame) - view.bounds.height + 10
        return spacing > 0 ? spacing : 0
    }

    private func emailIsValid(email: String) -> Bool {
        return emailErrorMessage(email) == nil
    }

    private func emailErrorMessage(email: String) -> String? {
        if email.isEmpty {
            return InterfaceString.Join.EmailRequired
        }
        else if email.isValidEmail() {
            return nil
        }
        else {
            return InterfaceString.Join.EmailInvalid
        }
    }

    private func emailAvailability(text: String, completion: (Bool) -> Void) {
        AvailabilityService().emailAvailability(text, success: { availability in
            if text != self.emailField.text {
                completion(false)
                return
            }

            if !availability.isEmailAvailable {
                let msg = InterfaceString.Join.EmailInvalid
                self.showErrorLabel(msg)
                completion(false)
            }
            else {
                completion(true)
            }
        }, failure: { error, _ in
            let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
            self.showErrorLabel(errorTitle)
            completion(false)
        })
    }

    private func usernameAvailability(text: String, completion: (Bool) -> Void) {
        AvailabilityService().usernameAvailability(text, success: { availability in
            if text != self.usernameField.text {
                completion(false)
                return
            }

            if !availability.isUsernameAvailable {
                let msg = InterfaceString.Join.UsernameUnavailable
                self.showErrorLabel(msg)

                if !availability.usernameSuggestions.isEmpty {
                    let suggestions = availability.usernameSuggestions.joinWithSeparator(", ")
                    let msg = String(format: InterfaceString.Join.UsernameSuggestionTemplate, suggestions)
                    self.showMessageLabel(msg)
                }
                completion(false)
            }
            else {
                self.hideMessageLabel()
                completion(true)
            }
        }, failure: { error, _ in
            let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
            self.showErrorLabel(errorTitle)
            self.hideMessageLabel()
            completion(false)
        })
    }

    private func usernameIsValid(username: String) -> Bool {
        return usernameErrorMessage(username) == nil
    }

    private func usernameErrorMessage(username: String) -> String? {
        if username.isEmpty {
            return InterfaceString.Join.UsernameRequired
        }
        else {
            return nil
        }
    }

    private func passwordIsValid(password: String) -> Bool {
        return passwordErrorMessage(password) == nil
    }

    private func passwordErrorMessage(password: String) -> String? {
        if password.isValidPassword() {
            return nil
        }
        else {
            return InterfaceString.Join.PasswordInvalid
        }
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
                self.emailField.text = email
            }
            else {
                self.emailField.becomeFirstResponder()
            }

            if let password = loginDict?[AppExtensionPasswordKey] as? String {
                self.passwordField.text = password
            }
        }
    }
}
