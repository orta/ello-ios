//
//  ProfileInfoViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class ProfileInfoViewController: BaseElloViewController, OnboardingStep {
    weak var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData? {
        didSet {
            if let image = onboardingData?.coverImage {
                chooseCoverImageView?.image = image
            }
            if let image = onboardingData?.avatarImage {
                chooseAvatarImageView?.image = image
            }
        }
    }

    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    var chooseCoverImageView: UIImageView?
    var chooseAvatarImageView: UIImageView?

    var nameField: UITextField?
    var bioField: UITextField?
    var linksField: UITextField?

    override public func loadView() {
        view = UIScrollView(frame: UIScreen.mainScreen().bounds)
    }

    var scrollView: UIScrollView { return self.view as! UIScrollView }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let chooseCoverImage = UIImage(named: "choose-header-image")!
        let aspect = view.frame.width / chooseCoverImage.size.width
        let chooseCoverImageView = UIImageView(frame: CGRect(
            x: 0,
            y: -87,
            width: view.frame.width,
            height: chooseCoverImage.size.height * aspect
            ))
        chooseCoverImageView.contentMode = .ScaleAspectFill
        chooseCoverImageView.clipsToBounds = true
        chooseCoverImageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseCoverImageView.image = onboardingData?.coverImage ?? chooseCoverImage
        view.addSubview(chooseCoverImageView)
        self.chooseCoverImageView = chooseCoverImageView

        let chooseAvatarImage = UIImage(named: "choose-avatar-image")!
        let scale = view.frame.width / CGFloat(375)
        let chooseAvatarImageView = UIImageView(frame: CGRect(
            x: 17.5 * scale,
            y: chooseCoverImageView.frame.maxY - 65,
            width: chooseAvatarImage.size.width * scale,
            height: chooseAvatarImage.size.height * scale
            ))
        chooseAvatarImageView.autoresizingMask = .FlexibleBottomMargin | .FlexibleRightMargin
        chooseAvatarImageView.image = onboardingData?.avatarImage ?? chooseAvatarImage
        chooseAvatarImageView.clipsToBounds = true
        chooseAvatarImageView.layer.cornerRadius = chooseAvatarImageView.frame.size.width / 2
        chooseAvatarImageView.contentMode = .ScaleAspectFill
        view.addSubview(chooseAvatarImageView)
        self.chooseAvatarImageView = chooseAvatarImageView

        let nameField = generateTextField(placeholder: NSLocalizedString("Name (optional)", comment: "Name (optional) placeholder text"),
            font: UIFont.typewriterBoldFont(21),
            y: chooseAvatarImageView.frame.maxY + 44)
        view.addSubview(nameField)
        self.nameField = nameField

        let bioField = generateTextField(placeholder: NSLocalizedString("Bio (optional)", comment: "Bio (optional) placeholder text"),
            font: UIFont.typewriterFont(17),
            y: nameField.frame.maxY + 26)
        view.addSubview(bioField)
        self.bioField = bioField

        let linksField = generateTextField(placeholder: NSLocalizedString("Links (optional)", comment: "Links (optional) placeholder text"),
            font: UIFont.typewriterFont(17),
            y: bioField.frame.maxY + 26)
        view.addSubview(linksField)
        self.linksField = linksField
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let linksField = linksField {
            let margin = CGFloat(15)
            scrollView.contentSize = CGSize(width: view.frame.width, height: linksField.frame.maxY + margin)
        }
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupNotificationObservers()
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
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
    }

}

extension ProfileInfoViewController {

    private func generateTextField(#placeholder: String, font: UIFont, y: CGFloat) -> UITextField {
        let field = UITextField(frame: CGRect(
            x: 15,
            y: y,
            width: view.frame.width - 30,
            height: 34
            ))
        field.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        field.font = font
        field.placeholder = placeholder
        let line = UIView(frame: CGRect(x: 0, y: field.frame.height - 2, width: field.frame.width, height: 2))
        line.backgroundColor = .greyE5()
        line.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        field.addSubview(line)
        return field
    }

}
