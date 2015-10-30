//
//  ProfileInfoViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class ProfileInfoViewController: OnboardingUploadImageViewController {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    var nameField: UITextField?
    var bioField: UITextField?
    var linksField: UITextField?

    override public func loadView() {
        view = UIScrollView(frame: UIScreen.mainScreen().bounds)
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }

    var scrollView: UIScrollView { return self.view as! UIScrollView }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Profile Info"

        scrollView.keyboardDismissMode = .OnDrag

        setupChooseCoverImageView()
        setupChooseAvatarImageView()
        setupTextFields()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let linksField = linksField {
            let margin = CGFloat(15)
            scrollView.contentSize = CGSize(width: view.frame.width, height: linksField.frame.maxY + margin)
        }

        let chooseCoverImage = chooseCoverImageDefault()
        let chooseAvatarImage = chooseAvatarImageDefault()
        let width = min(view.frame.width, Size.maxWidth)
        let aspect = width / chooseCoverImage.size.width
        let scale = width / CGFloat(375)

        chooseCoverImageView!.frame = CGRect(
            x: (view.frame.width - width) / 2,
            y: -87,
            width: width,
            height: chooseCoverImage.size.height * aspect
            )

        chooseAvatarImageView!.frame = CGRect(
            x: chooseCoverImageView!.frame.minX,
            y: chooseCoverImageView!.frame.maxY - 65,
            width: chooseAvatarImage.size.width * scale,
            height: chooseAvatarImage.size.height * scale
            )
        chooseAvatarImageView!.layer.cornerRadius = chooseAvatarImageView!.frame.size.width / 2

        nameField!.frame = CGRect(
            x: (view.frame.width - width) / 2,
            y: chooseAvatarImageView!.frame.maxY + 44,
            width: width,
            height: 34
            )
        bioField!.frame = CGRect(
            x: (view.frame.width - width) / 2,
            y: nameField!.frame.maxY + 26,
            width: width,
            height: 34
            )
        linksField!.frame = CGRect(
            x: (view.frame.width - width) / 2,
            y: bioField!.frame.maxY + 26,
            width: width,
            height: 34
            )
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupNotificationObservers()
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }

    public override func onboardingStepBegin() {
        nameField?.text = onboardingData?.name ?? ""
        bioField?.text = onboardingData?.bio ?? ""
        linksField?.text = onboardingData?.links ?? ""

        onboardingViewController?.canGoNext = true
    }

    public override func onboardingWillProceed(proceed: (OnboardingData?) -> Void) {
        let name = nameField?.text ?? ""
        let links = linksField?.text ?? ""
        let bio = bioField?.text ?? ""

        onboardingData?.name = name
        onboardingData?.bio = bio
        onboardingData?.links = links

        var info = [String:String]()
        if !name.isEmpty {
            info["name"] = name
        }
        if !links.isEmpty {
            info["external_links"] = links
        }
        if !bio.isEmpty {
            info["unsanitized_short_bio"] = bio
        }

        if !info.isEmpty {
            ElloHUD.showLoadingHud()
            ProfileService().updateUserProfile(info, success: { _ in
                ElloHUD.hideLoadingHud()
                proceed(self.onboardingData)
                }, failure: { _ in
                    ElloHUD.hideLoadingHud()
                    let message = NSLocalizedString("Something is wrong with those links.\n\nThey need to start with ‘http://’ or ‘https://’", comment: "Updating Links failed during onboarding message")
                    let alertController = AlertViewController(message: message)

                    let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
                    alertController.addAction(action)

                    logPresentingAlert("ProfileInfoViewController")
                    self.presentViewController(alertController, animated: true, completion: nil)
            })
        }
        else {
            proceed(self.onboardingData)
        }
    }

}

// MARK: View setup
private extension ProfileInfoViewController {
    func setupChooseCoverImageView() {
        let chooseCoverImage = chooseCoverImageDefault()
        let width = min(view.frame.width, Size.maxWidth)
        let aspect = width / chooseCoverImage.size.width
        let chooseCoverImageView = UIImageView(frame: CGRect(
            x: (view.frame.width - width) / 2,
            y: -87,
            width: width,
            height: chooseCoverImage.size.height * aspect
            ))
        chooseCoverImageView.contentMode = .ScaleAspectFill
        chooseCoverImageView.clipsToBounds = true
        chooseCoverImageView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        chooseCoverImageView.image = onboardingData?.coverImage ?? chooseCoverImage
        view.addSubview(chooseCoverImageView)
        self.chooseCoverImageView = chooseCoverImageView
    }

    func setupChooseAvatarImageView() {
        let chooseAvatarImage = chooseAvatarImageDefault()
        let width = min(view.frame.width, Size.maxWidth)
        let scale = width / CGFloat(375)
        let chooseAvatarImageView = UIImageView(frame: CGRect(
            x: chooseCoverImageView!.frame.minX,
            y: chooseCoverImageView!.frame.maxY - 65,
            width: chooseAvatarImage.size.width * scale,
            height: chooseAvatarImage.size.height * scale
            ))
        chooseAvatarImageView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
        chooseAvatarImageView.image = onboardingData?.avatarImage ?? chooseAvatarImage
        chooseAvatarImageView.clipsToBounds = true
        chooseAvatarImageView.layer.cornerRadius = chooseAvatarImageView.frame.size.width / 2
        chooseAvatarImageView.contentMode = .ScaleAspectFill
        view.addSubview(chooseAvatarImageView)
        self.chooseAvatarImageView = chooseAvatarImageView
    }

    func setupTextFields() {
        let nameField = generateTextField(placeholder: NSLocalizedString("Name (optional)", comment: "Name (optional) placeholder text"),
            font: UIFont.typewriterBoldFont(18),
            y: chooseAvatarImageView!.frame.maxY + 44)
        view.addSubview(nameField)
        self.nameField = nameField

        let bioField = generateTextField(placeholder: NSLocalizedString("Bio (optional)", comment: "Bio (optional) placeholder text"),
            font: UIFont.typewriterFont(12),
            y: nameField.frame.maxY + 26)
        bioField.autocapitalizationType = .Sentences
        bioField.autocorrectionType = .Default
        bioField.spellCheckingType = .Default
        view.addSubview(bioField)
        self.bioField = bioField

        let linksField = generateTextField(placeholder: NSLocalizedString("Links (optional)", comment: "Links (optional) placeholder text"),
            font: UIFont.typewriterFont(12),
            y: bioField.frame.maxY + 26)
        linksField.keyboardType = .URL
        linksField.returnKeyType = .Go
        view.addSubview(linksField)
        self.linksField = linksField
    }
}

public extension ProfileInfoViewController {

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

        if keyboard.bottomInset == 0 {
            scrollView.scrollEnabled = false
        }
        else {
            scrollView.scrollEnabled = true
        }
    }

}

extension ProfileInfoViewController: UITextFieldDelegate {

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case nameField!:
            bioField!.becomeFirstResponder()
        case bioField!:
            linksField!.becomeFirstResponder()
        case linksField!:
            linksField!.resignFirstResponder()
        default:
            return false
        }
        return true
    }

}

extension ProfileInfoViewController {

    private func generateTextField(placeholder placeholder: String, font: UIFont, y: CGFloat) -> UITextField {
        let width = min(view.frame.width, Size.maxWidth) - 30
        let field = UITextField(frame: CGRect(
            x: (view.frame.width - width) / 2,
            y: y,
            width: width,
            height: 34
            ))
        field.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        field.font = font
        field.textColor = .greyA()
        field.placeholder = placeholder
        field.delegate = self

        field.autocapitalizationType = .None
        field.autocorrectionType = .No
        field.spellCheckingType = .No
        field.keyboardAppearance = .Dark
        field.enablesReturnKeyAutomatically = false
        field.returnKeyType = .Next
        field.keyboardType = .Default

        let height = CGFloat(1)
        let line = UIView(frame: CGRect(x: 0, y: field.frame.height - height, width: field.frame.width, height: height))
        line.backgroundColor = .greyE5()
        line.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        field.addSubview(line)
        return field
    }

}
